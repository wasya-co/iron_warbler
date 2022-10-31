
## copy-pasted from ish_api
class IronWarbler::ApiController < ActionController::Base

  # skip_authorization_check only: %i| fb_sign_in login |

  before_action :check_profile_auth, only: %i| account |

  def authorize! *args
    true
  end

  ## @TODO: this is not test-driven
  def account
    @profile = current_user&.profile
    authorize! :show, @profile
    render 'iron_warbler/api/account'
  rescue CanCan::AccessDenied
    render json: {
      status: :not_ok,
    }, status: 401
  end

  def fb_sign_in
    authorize! :fb_sign_in, Ishapi
    # render :json => { :status => :ok }
    render :action => 'show'
  end

  def home
    render json: { status: :ok }, status: :ok
  end

  def login
    @current_user = User.where( email: params[:email] ).first
    if !@current_user
      render json: { status: :not_ok }, status: 401
      return
    end
    if @current_user.valid_password?(params[:password])
      # from: application_controller#long_term_token

      # send the jwt to client
      @jwt_token = encode(user_id: @current_user.id.to_s)
      @profile = @current_user.profile
    end
  end

  ## POST /api/users/long_term_token , a FB login flow
  def long_term_token
    accessToken   = request.headers[:accessToken]
    accessToken ||= params[:accessToken]

    params['domain'] = 'tgm.piousbox.com'

    response = ::HTTParty.get "https://graph.facebook.com/v5.0/oauth/access_token?grant_type=fb_exchange_token&" +
      "client_id=#{::FB[params['domain']][:app]}&client_secret=#{::FB[params['domain']][:secret]}&" +
      "fb_exchange_token=#{accessToken}"
    j = JSON.parse response.body
    @long_term_token  = j['access_token']
    @graph            = Koala::Facebook::API.new( accessToken )
    @me               = @graph.get_object( 'me', :fields => 'email' )
    @current_user     = User.where( :email => @me['email'] ).first

    # send the jwt to client
    @jwt_token = encode(user_id: @current_user.id.to_s)

    render json: {
      email: @current_user.email,
      jwt_token: @jwt_token,
      long_term_token: @long_term_token,
      n_unlocks: @current_user.profile.n_unlocks,
    }
  end

  private

  ## This returns an empty user if not logged in
  def check_profile
    begin
      decoded = decode(params[:jwt_token])
      @current_user = User.find decoded['user_id']
    rescue JWT::ExpiredSignature, JWT::DecodeError => e
      # flash[:notice] = 'You are not logged in, or you have been logged out.'
      # puts! 'You are not logged in, or you have been logged out.'
      @current_user = User.new
    end
  end

  ## This errors out if not logged in
  def check_profile_auth
    check_jwt
  end

  ## jwt
  ## This errors out if not logged in, same as #check_profile_auth
  def check_jwt
    begin
      decoded = decode(params[:jwt_token])
      @current_user = User.find decoded['user_id']
    rescue JWT::ExpiredSignature
      Rails.logger.info("JWT::ExpiredSignature")
    rescue JWT::DecodeError
      Rails.logger.info("JWT::DecodeError")
    end
    current_ability
  end

  def current_ability
    @current_ability ||= IronWarbler::Ability.new(current_user)
  end

  def current_user
    @current_user
  end

  # jwt
  def decode(token)
    decoded = ::JWT.decode(token, Rails.application.secrets.secret_key_base.to_s)[0]
    HashWithIndifferentAccess.new decoded
  end

  # jwt
  def encode(payload, exp = 48.hours.from_now) # @TODO: definitely change, right now I expire once in 2 days.
    payload[:exp] = exp.to_i
    ::JWT.encode(payload, Rails.application.secrets.secret_key_base.to_s)
  end


end


