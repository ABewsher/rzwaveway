rzwaveway
=========

A Ruby library for communicating with the ZWave protocol stack from ZWay, running on the Raspberry Pi "razberry" add-on card (see http://razberry.z-wave.me/).

## Example
```
require 'rzwaveway'

z_way = RZWaveWay::ZWay.new('192.168.1.123')
devices = z_way.get_devices
devices.values.each do | device |
  puts device.build_json
end

z_way.on_event(RZWaveWay::AliveEvent) {|event| puts "A device woke up" }
z_way.on_event(RZWaveWay::LevelEvent) {|event| puts "A device got triggered" }
while true do
  sleep 5
  z_way.process_events
end
```
