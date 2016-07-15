require 'json'

module RZWaveWay
  class Controller
    attr_reader :state
    attr_reader :devices

    def initialize(data, devices)
      @state = 0
      @devices = devices
    end

    def process(key, data)
      events = []
      case key
      when "controller.data.controllerState"
        new_state = data['value'].to_i
        # $update_time = '0' if state == 1 && new_state == 0
        @state = new_state
        # $poll_time = 10 if state == 1
        events << ControllerStateEvent.new(state, human)
      when "controller.data.lastIncludedDevice"
        id = data['value']
        events << LastIncludedDeviceEvent.new(id, @devices[id].device_type, @devices[id]) if id
      else
        events << UnknownEvent.new(key, data)
      end
      events
    end

    protected

    def human
      case @state
      when 0
        'normal'
      when 1
        'inclusion'
      when 5
        'exclusion'
      else
        "unknown(#{@state})"
      end
    end
  end
end
