
Pu  ||= Iro::Purse
Str ||= Iro::Strategy
Po  ||= Iro::Position
O   ||= Iro::Option
Sto ||= Iro::Stock

class Schwab
  include HTTParty
  debug_output $stdout
end

class Iro::ApplicationController < Wco::ApplicationController
  layout 'iro/application'

  before_action :set_lists, except: %i| schwab_sync |

  def home
    authorize! :home, Iro
  end

  def schwab_sync
    authorize! :shwab_sync, Iro
    profile = Wco::Profile.find_by email: 'piousbox@gmail.com'

    out = Schwab.post( "https://api.schwabapi.com/v1/oauth/token", {
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      basic_auth: { username: SCHWAB_DATA[:key], password: SCHWAB_DATA[:secret] },
      body: {
        grant_type: 'refresh_token',
        refresh_token: profile.schwab_refresh_token
      },
    })
    out = out.parsed_response
    puts! out, 'out'

    attrs = {
      schwab_access_token:  out['access_token'],
      schwab_refresh_token: out['refresh_token'],
      schwab_id_token:      out['id_token'],
    }
    # puts! attrs, 'attrs'

    profile.update(attrs)
    profile.save!

    render json: { status: :ok }
  end

  ##
  ## private
  ##
  private

  def set_lists
    @purses = Iro::Purse.all
    @strategies = Iro::Strategy.all
    @strategies_list = Iro::Strategy.list
  end


end
