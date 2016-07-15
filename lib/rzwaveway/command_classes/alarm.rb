require 'byebug'

module RZWaveWay
  module CommandClasses
    class Alarm
      include CommandClass

      def initialize(data, device)
        @device = device
        @device.add_property(name: :access_control,
                             value: find('data.6.eventString.value', data),
                             update_time: find('data.6.eventString.updateTime', data))

        @device.add_property(name: :burglar,
                             value: find('data.7.eventString.value', data),
                             update_time: find('data.7.eventString.updateTime', data))
      end

      def process(updates)
        events = []
        if updates.keys.include?('data.6')
          data = updates['data.6']
          event = data['eventString']
          if event
            human = event['value']
            value = access_control_value_from(human)
            update_time = event['updateTime']
            if @device.update_property(:access_control, value, update_time)
              events << LevelEvent.new(@device.id, @device.name, update_time, value, human)
            end
          end
        end

        if updates.keys.include?('data.7')
          data = updates['data.7']
          event = data['eventString']
          if event
            human = event['value']
            value = burgler_value_from(human)
            update_time = event['updateTime']
            if @device.update_property(:burglar, value, update_time)
              events << TamperEvent.new(@device.id, update_time, value, human)
            end
          end
        end
        events
      end

      def get
        RZWaveWay::ZWay.instance.execute(@device.id, ALARM, :Get)
      end

      protected

      def access_control_value_from(human)
        human.include?('open')
      end

      def burgler_value_from(human)
        human != ''
      end
    end
  end
end
