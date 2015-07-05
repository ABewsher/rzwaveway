module RZWaveWay
  module CommandClasses
    class Battery
      include CommandClass

      def initialize(data, device)
        @device = device
        @device.add_property(:battery_level,
                             find('data.last.value', data),
                             find('data.last.updateTime', data))
      end

      def process(updates)
        if updates.keys.include?('data.last')
          data = updates['data.last']
          value = data['value']
          updateTime = data['updateTime']
          if @device.update_property(:battery_level, value, updateTime)
            return BatteryValueEvent.new(@device.id, updateTime, value)
          end
        end
      end

      def battery_value
        @device.get_property(:battery_level)[0]
      end

      def get
        RZWaveWay::ZWay.instance.execute(@device.id, BATTERY, :Get)
      end
    end
  end
end
