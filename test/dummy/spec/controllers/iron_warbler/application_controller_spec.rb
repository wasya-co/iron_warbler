require 'spec_helper'

describe IronWarbler::ApplicationController, type: :controller do
  routes { IronWarbler::Engine.routes }
  render_views
  before do
    setup_users
  end

  it '#home' do
    get :home
    response.code.should eql '200'
  end

end
