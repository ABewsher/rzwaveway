require 'singleton'

require_relative 'command_class'
require_relative 'command_classes/battery'
require_relative 'command_classes/sensor_binary'
require_relative 'command_classes/wake_up'

module RZWaveWay
  module CommandClasses
    class Dummy
      include Singleton

      def initialize
      end

      def process(updates, device)
      end
    end

    class Factory
      include Singleton
      include CommandClass

      def instantiate(id, data, device)
        if CLASSES.has_key? id
          return CLASSES[id].new(data, device)
        else
          return CommandClasses::Dummy.instance
        end
      end

      private

      CLASSES = {
        SENSOR_BINARY => CommandClasses::SensorBinary,
        WAKEUP => CommandClasses::WakeUp,
        BATTERY => CommandClasses::Battery
      }
    end
  end
end
