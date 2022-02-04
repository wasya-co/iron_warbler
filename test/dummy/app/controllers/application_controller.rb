class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def home
  end

  private

  def set_current_ability
    @current_ability ||= Ability.new( current_user )
  end

end
