require 'json'

module RZWaveWay
  class AliveEvent
    attr_reader :device_id
    attr_reader :time

    def initialize device_id, time
      @device_id = device_id
      @time = time
    end
  end

  class NotAliveEvent
    attr_reader :device_id
    attr_reader :time_delay
    attr_reader :missed_count

    def initialize(device_id, time_delay, missed_count)
      @device_id = device_id
      @time_delay = time_delay
      @missed_count = missed_count
    end
  end

  class ControllerStateEvent
    attr_reader :state
    attr_reader :human

    def initialize(value, human)
      @state = value
      @human = human
    end
  end

  class CommandClassEvent
    attr_reader :device_id
    attr_reader :cc_id
    attr_reader :data

    def initialize(device_id, cc_id, data)
      @device_id = device_id
      @cc_id = cc_id
      @data = data.to_json
    end
  end

  class DeadEvent
    attr_reader :device_id

    def initialize(device_id)
      @device_id = device_id
    end
  end

  class LastIncludedDeviceEvent
    attr_reader :device_id
    attr_reader :device_type
    attr_reader :data

    def initialize(device_id, device_type = nil, data = nil)
      @device_id = device_id
      @device_type = device_type
      @data = data
    end
  end

  class LevelEvent
    attr_reader :device_id
    attr_reader :device_name
    attr_reader :time
    attr_reader :level
    attr_reader :human

    def initialize(device_id, device_name, time, level, human = nil)
      @device_id = device_id
      @device_name = device_name
      @time = time
      @level = level
      @human = human || level
    end
  end

  class MultiLevelEvent < LevelEvent
  end

  class BatteryValueEvent
    attr_reader :device_id
    attr_reader :time
    attr_reader :value

    def initialize(device_id, time, value)
      @device_id = device_id
      @time = time
      @value = value
    end
  end

  class SmokeEvent
    attr_reader :device_id
    attr_reader :time
  end

  class HighTemperatureEvent
    attr_reader :device_id
    attr_reader :time
  end

  class TamperEvent
    attr_reader :device_id
    attr_reader :time
    attr_reader :value
    attr_reader :human

    def initialize(device_id, time, value, human = nil)
      @device_id = device_id
      @time = time
      @value = value
      @human = human || value
    end
  end

  class UnknownEvent
    attr_reader :event_name
    attr_reader :data

    def initialize(name, data)
      @event_name = name
      @data = data
    end
  end
end
