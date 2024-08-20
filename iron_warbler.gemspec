
Gem::Specification.new do |spec|
  spec.name        = 'iron_warbler'
  spec.version     = '2.0.7.40'
  spec.authors     = [ 'Victor Pudeyev' ]
  spec.email       = 'victor@wasya.co'
  spec.homepage    = 'https://wasya.co'
  spec.summary     = 'Stocks and Options Trading Bot'
  spec.description = 'A stocks and Options Trading Bot.'
  spec.license     = 'Proprietary'

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = "https://wasya.co"
  spec.metadata["changelog_uri"]   = "https://wasya.co"

  spec.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.txt"]

  ##
  ## Edit the template, not the gemspec!
  ##
  spec.add_dependency "business_time"
  spec.add_dependency "cancancan",  "~> 3.5.0"
  spec.add_dependency 'devise',     "~> 4.9.3"
  spec.add_dependency 'exception_notification', "~> 4.5.0"
  spec.add_dependency 'haml',                   '~> 6.3.0'
  spec.add_dependency 'httparty',               '~> 0.21.0'
  spec.add_dependency 'jbuilder',               '~> 2.11.0'
  spec.add_dependency 'mongoid',                '~> 7.3.0'
  spec.add_dependency 'rails',                  '~> 6.1.0'

  spec.add_dependency 'wco_models', '~> 3.1.0'

  spec.add_dependency 'omniauth',                       '~> 2.1.1'
  spec.add_dependency "omniauth-keycloak",              "~> 1.5.1"
  spec.add_dependency "omniauth-rails_csrf_protection", "~> 1.0.1"
  # spec.add_dependency 'rb-gsl'
  spec.add_dependency 'distribution'

end
