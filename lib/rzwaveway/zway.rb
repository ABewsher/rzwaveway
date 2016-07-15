require 'singleton'

require 'httpclient/webagent-cookie'
require 'faraday-cookie_jar'
require 'faraday'
require 'log4r'
require 'json'

module RZWaveWay
  class ZWay
    include Singleton
    include Log4r

    attr_reader :devices
    attr_reader :log

    def initialize
      @log = default_logger
      @event_handlers = {}
      @devices = {}
      $update_time = '0'
    end

    def execute(device_id, command_class, command_class_function, argument = nil)
      raise "No device with id '#{device_id}'" unless @devices.key?(device_id)
      raise "Device with id '#{device_id}' does not support command class '#{command_class}'" unless @devices[device_id].support_commandclass?(command_class)

      run_zway "devices[#{device_id}].instances[0].commandClasses[#{command_class}].#{command_class_function.to_s}(#{argument})"
    end

    def find_extension(name, device_id)
      device = @devices[device_id.to_i]
      raise ArgumentError, "No device with id '#{device_id}'" unless device
      clazz = qualified_const_get "RZWaveWay::Extensions::#{name}"
      clazz.new(device)
    end

    def setup(options, *adapter_params)
      hostname = options[:hostname] || '127.0.0.1'
      port = options[:port] || 8083
      adapter_params = :httpclient if adapter_params.compact.empty?
      @base_uri="http://#{hostname}:#{port}"
      @connection = Faraday.new do |faraday|
        faraday.use :cookie_jar
        faraday.adapter(*adapter_params)
      end
      @log = options[:logger] if options.key? :logger
      login(options[:username], options[:password])
    end

    def start(poll_time = 0)
      $poll_time = poll_time
      @requested_poll_time = poll_time
      results = get_zway_data_tree_updates

      @controller = Controller.new(results['controller'], @devices) if results.key?('controller')

      if results.key?('devices')
        build_devices results['devices']
      end

      return if $poll_time == 0

      log.debug "Starting polling every #{$poll_time} seconds."
      @poller ||= Thread.new do
        loop do
          pt = $poll_time
          $poll_time = @requested_poll_time unless @controller.state == 1
          sleep pt
          begin
            process_events
          rescue Exception => e
            log.error e.message
            log.error e.backtrace.inspect
          end
        end
      end
    end

    def stop
      @poller.kill if @poller
    end

    def on_event(event, &listener)
      @event_handlers[event] = listener
    end

    def begin_add_device
      run_zway 'controller.AddNodeToNetwork(1)'
    end

    def end_add_device
      run_zway 'controller.AddNodeToNetwork(0)'
    end

    def begin_remove_device
      run_zway 'controller.RemoveNodeFromNetwork(1)'
    end

    def end_remove_device
      run_zway 'controller.RemoveNodeFromNetwork(0)'
    end

    def process_events
      check_devices
      updates = get_zway_data_tree_updates
      events = []

      updates.each do | key, value |
        if key == 'devices'
          build_devices value
        elsif key.start_with?('devices')
          match_data = key.match(/\Adevices\.(\d+)\./)
          if match_data
            device_id = match_data[1].to_i
            if device_id > 1
              if  @devices[device_id]
                device_events = @devices[device_id].process(match_data.post_match => value)
                events += device_events unless device_events.empty?
              else
                log.warn "Could not find device with id '#{device_id}'"
                log.debug("VALUE: #{value.inspect}")
              end
            end
          else
            log.debug "No device group match for key='#{key}'"
            log.debug("VALUE: #{value.inspect}")
          end
        elsif key.start_with?('controller')
          controller_events = @controller.process(key, value)
          events += controller_events unless controller_events.empty?
        else
          log.debug "Unknown key type = '#{key}'"
          log.debug("VALUE: #{value.inspect}")
        end
      end

      check_not_alive_devices!(events)
      deliver_to_handlers(events)
    end

    private

    def build_devices(data)
      data.each do |device_id, device_data_tree|
        id = device_id.to_i
        if id > 1
          log.debug "Tracking device #{id}."
          @devices[id] = ZWaveDevice.new(id, device_data_tree) unless @devices.key?(id)
        end
      end
    end

    def check_devices
      return
      # AB 15/7/2016 This method sometimes breaks when new devices are added.
      # disabling it for now.
      @devices.values.each do |device|
        unless device.contacts_controller_periodically?
          current_time = Time.now.to_i
          # TODO ensure last_contact_time is set in the device initializer
          if (current_time % 10 == 0) && (current_time > device.next_contact_time - 60)
            run_zway "devices[#{device.id}].SendNoOperation()"
          end
        end
      end
    end

    def check_not_alive_devices!(events)
      @devices.values.each do |device|
        event = device.process_alive_check
        events << event if event
      end
    end

    def default_logger
      Log4r::Logger.new 'RZWaveWay'
    end

    def deliver_to_handlers events
      events.each do |event|
        handler = @event_handlers[event.class]
        if handler
          handler.call(event)
        else
          log.debug "No event handler for #{event.class}"
        end
      end
    end

    def get_zway_data_tree_updates
      results = api_post "/ZWaveAPI/Data/#{$update_time}"
      $update_time = results.delete('updateTime') unless results.empty?
      results
    end

    def login(username = 'local', password = 'local')
      api_post '/ZAutomation/api/v1/login',
               %Q({ "form":"true","login":"#{username}","password":"#{password}","keepme":"false","default_ui":1 })
    end

    def qualified_const_get(str)
      path = str.to_s.split('::')
      from_root = path[0].empty?
      if from_root
        from_root = []
        path = path[1..-1]
      else
        start_ns = ((Class === self)||(Module === self)) ? self : self.class
        from_root = start_ns.to_s.split('::')
      end
      until from_root.empty?
        begin
          return (from_root+path).inject(Object) { |ns,name| ns.const_get(name) }
        rescue NameError
          from_root.delete_at(-1)
        end
      end
      path.inject(Object) { |ns,name| ns.const_get(name) }
    end

    def run_zway(command_path)
      api_post '/ZWaveAPI/Run/' + command_path
    end

    def api_post(path, body = '{}')
      results = {}
      url = URI.encode(@base_uri + path, '[]')
      begin
        response = @connection.post do |req|
          req.url url
          req.headers['Content-Type'] = 'application/json'
          req.headers['Accept'] = 'application/json'
          req.body = body
        end
        if response.success?
          results = JSON.parse response.body
        else
          log.error(response.status)
          log.error(response.body)
        end
      rescue StandardError => e
        log.error("Failed to communicate with ZWay HTTP server: #{e}")
        byebug
      end
      results
    end
  end
end
