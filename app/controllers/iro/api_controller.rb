
class Schwab
  include HTTParty
  debug_output $stdout
end

class Iro::ApiController < ActionController::Base
  layout false

  before_action :decode_jwt, except: [ :oauth2_redirect ]

  def oauth2_redirect
    out = Schwab.post( "https://api.schwabapi.com/v1/oauth/token", {
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      basic_auth: { username: SCHWAB_DATA[:key], password: SCHWAB_DATA[:secret] },
      body: {
        grant_type: 'authorization_code',
        code: params[:code].sub('%40', '@'),
        redirect_uri: SCHWAB_DATA[:redirect_url],
      },
    })
    out = out.parsed_response

    attrs = {
      schwab_access_token:  out['access_token'],
      schwab_refresh_token: out['refresh_token'],
      schwab_id_token:      out['id_token'],
    }
    # puts! attrs, 'attrs'

    profile = Wco::Profile.find_by email: 'piousbox@gmail.com'
    profile.update(attrs)
    profile.save!

    render json: { status: :ok }
  end

  ##
  ## private
  ##
  private

  def decode_jwt
    out = JWT.decode params[:jwt_token], nil, false
    email = out[0]['email']
    user = User.find_by({ email: email })
    sign_in user
  end

end
