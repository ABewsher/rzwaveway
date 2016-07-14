$LOAD_PATH.unshift 'lib'
require 'rzwaveway/version'

Gem::Specification.new do |s|
  s.name = 'rzwaveway'
  s.version = RZWaveWay::VERSION
  s.authors = ['Vincent Touchard','Adam Bewsher']
  s.date = '2016-07-13'
  s.summary = 'ZWave API for ZWay'
  s.description = 'A Ruby API to use the Razberry ZWave ZWay interface'
  s.email = 'touchardv@yahoo.com'
  s.homepage = 'https://github.com/touchardv/rzwaveway'
  s.files = `git ls-files`.split("\n")
  s.has_rdoc = false

  dependencies = [
    [:runtime, 'log4r', '~> 1.1.10'],
    [:runtime, 'byebug'],
    [:runtime, 'faraday'],
    [:runtime, 'faraday-cookie_jar'],
    [:runtime, 'httpclient'],
    [:development, 'bundler', '~> 1.0'],
    [:development, 'rspec', '~> 3.0.0']
  ]

  dependencies.each do |type, name, version|
    if s.respond_to?("add_#{type}_dependency")
      s.send("add_#{type}_dependency", name, version)
    else
      s.add_dependency(name, version)
    end
  end
end
