
Gem::Specification.new do |spec|
  spec.name        = 'iron_warbler'
  spec.version     = '2.0.2'
  spec.authors     = [ 'Victor Pudeyev' ]
  spec.email       = 'victor@wasya.co'
  spec.homepage    = 'https://wasya.co'
  spec.summary     = 'Stocks and Options Trading Bot'
  spec.description = 'Stocks and Options Trading Bot'
  spec.license     = 'Proprietary'

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://wasya.co"
  spec.metadata["changelog_uri"] = "https://wasya.co"

  spec.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.txt"]

  spec.add_dependency 'rails', '~> 6.1.0'
  spec.add_dependency 'httparty', '~> 0.21.0'
  spec.add_dependency 'jwt', '~> 2.3.0'
  spec.add_dependency 'jbuilder', '~> 2.11.0'
  spec.add_dependency 'mysql2', '~> 0.5.5'
  spec.add_dependency 'cancancan', '~> 3.4.0'
  spec.add_dependency 'haml', '~> 5.2.0'

end
