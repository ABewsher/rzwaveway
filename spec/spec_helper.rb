require 'rzwaveway'
require 'log4r'
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

$log = Log4r::Logger.new 'RZWaveWay'
# formatter = Log4r::PatternFormatter.new(:pattern => "[%l] %d - %m")
# outputter = Log4r::Outputter.stdout
# outputter.formatter = formatter
# outputter.level = Log4r::DEBUG
# $log.outputters = [Log4r::Outputter.stdout]
