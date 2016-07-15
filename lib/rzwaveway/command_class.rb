module RZWaveWay
  module CommandClass
    BASIC = 32
    APPLICATION_STATUS = 34
    SWITCH_BINARY = 37
    SWITCH_MULTI_LEVEL = 38
    SCENE_ACTIVATION = 43
    SENSOR_BINARY = 48
    SENSOR_MULTI_LEVEL = 49
    CRC16 = 86
    ASSOCIATION_GROUP_INFORMATION = 89
    DEVICE_RESET_LOCALLY = 90
    ZWAVE_PLUS_INFO = 94
    CONFIGURATION = 112
    ALARM = 113
    MANUFACTURER_SPECIFIC = 114
    POWER_LEVEL = 115
    FIRMWARE_UPDATE = 122
    BATTERY = 128
    WAKEUP = 132
    ASSOCIATION = 133
    VERSION = 134
    MULTI_CHANNEL_ASSOCIATION = 142
    SECURITY = 152
    ALARM_SENSOR = 156

    private

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
