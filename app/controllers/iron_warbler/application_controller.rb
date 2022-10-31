module IronWarbler
  class ApplicationController < ActionController::Base
    # protect_from_forgery :with => :exception, :prepend => true

    before_action :set_changelog

    # before_action :set_current_ability
    # check_authorization
    # rescue_from ::CanCan::AccessDenied, :with => :access_denied

    def home
      # authorize! :home, IronWarbler::Ability
      authorize! :open_permission, IronWarbler::Ability
    end

    #
    # private
    #
    private

    def authorize! *args
      true
    end

    # def current_user
    #   @current_user
    # end

    def set_changelog
      @version = Gem.loaded_specs['iron_warbler'].version.to_s
    end

    # def set_current_ability
    #   @current_ability ||= ::IronWarbler::Ability.new( current_user )
    # end

    def access_denied exception
      store_location_for :user, request.path
      redirect_to user_signed_in? ? root_path : Rails.application.routes.url_helpers.new_user_session_path, :alert => exception.message
    end

    def pp_errors err
      err
    end

    def puts! a, b=''
      puts "+++ +++ #{b}"
      puts a.inspect
    end

  end
end
