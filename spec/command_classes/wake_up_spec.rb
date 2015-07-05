require 'spec_helper'

module RZWaveWay
  module CommandClasses
    describe WakeUp do
      let(:device) { ZWaveDevice.new(create_id, create_device_data) }
      let(:command_class) do
        WakeUp.new(
          {'data' => {
             'interval' => {'value' => 300, 'updateTime' => 1394983000},
             'lastSleep' => {'value' => 1394983222, 'updateTime' => 1394983222},
             'lastWakeup' => {'value' => 1394983222, 'updateTime' => 1394983222}
        }}, device)
      end

      describe '#new' do
        it 'stores interesting properties' do
          command_class
          expect(device.get_property(:wakeup_interval)).to eq [300, 1394983000]
          expect(device.contact_frequency).to eq 300
          expect(device.get_property(:wakeup_last_sleep_time)).to eq [1394983222, 1394983222]
          expect(device.get_property(:wakeup_last_wakeup_time)).to eq [1394983222, 1394983222]
          expect(device.last_contact_time).to eq 1394983222
        end
      end

      describe '#process' do
        it 'does nothing when it processes no updates' do
          expect(command_class.process({})).to be_nil
        end

        it 'returns an alive event' do
          updates = {
            'data.lastWakeup' => {'value' => 1395247772, 'updateTime' => 1395247772},
            'data.lastSleep' => {'value' => 1395247772, 'updateTime' => 1395247772}
          }
          event = command_class.process(updates)
          expect(event.class).to be RZWaveWay::AliveEvent
          expect(event.device_id).to eq device.id
          expect(event.time).to eq 1395247772
        end
      end
    end
  end
end
