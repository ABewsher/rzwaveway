require 'json'

module RZWaveWay
  class ZWaveDeviceType
    attr_reader :basic_type
    attr_reader :generic_type
    attr_reader :specific_type
    attr_reader :command_classes

    def initialize(data, command_classes)
      @basic_type = find('data.basicType.value', data)
      @generic_type = find('data.genericType.value', data)
      @specific_type = find('data.specificType.value', data)
      @command_classes = command_classes
    end

    def human
      return 'Fibaro Door/Window Contact' if numbers_are? 1,4,7
      return 'Fibaro Flood Sensor' if numbers_are? 4,161,2
      return 'Fibaro Smoke Sensor' if numbers_are? 4,7,1
      return 'Fibaro Motion Sensor' if numbers_are? 4,7,1
      'Unknown'
    end

    def numbers_are?(b, g, s)
      basic_type == b && generic_type == g && specific_type == s
    end

    protected

    def find(name, data)
      parts = name.split '.'
      result = data
      parts.each do | part |
        unless result.has_key? part
          puts "Could not find part '#{part}' in '#{name}'"
          return data
        end
        result = result[part]
      end
      result
    end
  end
end
