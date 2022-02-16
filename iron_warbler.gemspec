
Gem::Specification.new do |s|
  s.name        = 'iron_warbler'
  s.version     = '0.0.1'
  s.date        = '2022-02-02'
  s.summary     = 'Stocks and Options Trading Bot'
  s.description = 'Stocks and Options Trading Bot'
  s.authors     = [ 'piousbox' ]
  s.email       = 'victor@wasya.co'
  s.files       = Dir[ "lib/*", "lib/**/*" ]
  s.homepage    = 'https://wasya.co'
  s.license     = 'Proprietary'

  s.add_runtime_dependency 'rails', '~> 6.0.0'
  s.add_runtime_dependency 'httparty', '~> 0.20.0'
  s.add_runtime_dependency 'kaminari-mongoid', '~> 1.0.2'
  s.add_runtime_dependency 'mongoid', '~> 7.3.0'
  s.add_runtime_dependency 'mongoid-autoinc', '~> 6.0.3'
  s.add_runtime_dependency 'mongoid_paranoia'
  s.add_runtime_dependency 'mongoid-paperclip'
  s.add_runtime_dependency 'jwt', '~> 2.3.0'
  s.add_runtime_dependency 'jbuilder', '~> 2.11.0'
  s.add_runtime_dependency 'pg', '~> 1.3.1'
  s.add_runtime_dependency 'cancancan', '~> 2.3.0'
  s.add_runtime_dependency 'haml', '~> 5.2.0'

  # s.add_runtime_dependency 'ish_models', '~> 0.0.33.156'

  # s.add_runtime_dependency 'devise'
  # s.add_runtime_dependency 'aws-sdk'

end
