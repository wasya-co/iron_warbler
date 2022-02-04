Devise.setup do |config|
  config.secret_key = 'bdff279e17a01823f7ac8544fa7b95bf5bbaa768801a1a337d56e7a1861fe0bcabc51b67536b423ce25d39dd7c0ae7795519c2f1d5845a8026ca5f3f53b40d84'
  config.mailer_sender = 'please-change-me-at-config-initializers-devise@example.com'
  config.email_regexp = /\A[^@\s]+@([^@\s]+\.)+[^@\W]+\z/
  require 'devise/orm/mongoid'
  config.case_insensitive_keys = [ :email ]
  config.strip_whitespace_keys = [ :email ]
  config.skip_session_storage = [:http_auth]
  config.clean_up_csrf_token_on_authentication = false
  config.stretches = Rails.env.test? ? 1 : 10
  config.reconfirmable = true
  config.password_length = 8..128
  config.reset_password_within = 6.hours
  config.sign_out_via = :delete
end

