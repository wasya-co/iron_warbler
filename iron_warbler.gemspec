
Gem::Specification.new do |s|
  s.name        = 'iron_warbler'
  s.version     = '0.0.3'
  s.date        = '2022-02-02'
  s.summary     = 'Stocks and Options Trading Bot'
  s.description = 'Stocks and Options Trading Bot'
  s.authors     = [ 'piousbox' ]
  s.email       = 'victor@wasya.co'
  s.files       = Dir[ "lib/*", "lib/**/*" ]
  s.homepage    = 'https://wasya.co'
  s.license     = 'Proprietary'

  s.add_runtime_dependency 'rails', '~> 6.1.0'
  s.add_runtime_dependency 'httparty', '~> 0.20.0'
  s.add_runtime_dependency 'jwt', '~> 2.3.0'
  s.add_runtime_dependency 'jbuilder', '~> 2.11.0'
  s.add_runtime_dependency 'mysql2', '~> 0.5.4'
  s.add_runtime_dependency 'cancancan', '~> 3.4.0'
  s.add_runtime_dependency 'haml', '~> 5.2.0'

end
