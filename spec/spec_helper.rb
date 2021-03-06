require 'rzwaveway'
require 'securerandom'

module SpecHelpers
  def create_id
    SecureRandom.random_number(1000000)
  end

  def create_device_data(command_classes_data = {}, last_contact_time = 0)
    {
      'data' => {
        'givenName' => {
          'value' => 'device name'
          },
        'lastReceived' => {
          'updateTime' => last_contact_time
        },
        'lastSend' => {
          'updateTime' => last_contact_time
        }
      },
      'instances' => {'0' => {'commandClasses' => command_classes_data}}
    }
  end
end

RSpec.configure do |c|
  c.include SpecHelpers
end
