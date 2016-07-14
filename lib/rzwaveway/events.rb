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

  class DeadEvent
    attr_reader :device_id

    def initialize(device_id)
      @device_id = device_id
    end
  end

  class LevelEvent
    attr_reader :device_id
    attr_reader :time
    attr_reader :level
    attr_reader :human

    def initialize(device_id, time, level, human = nil)
      @device_id = device_id
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
end
