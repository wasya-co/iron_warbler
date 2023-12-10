require 'rails_helper'

RSpec.describe "profiles/index", type: :view do
  before(:each) do
    assign(:profiles, [
      Profile.create!(
        email: "Email",
        role_name: "Role Name",
        user_id: 2
      ),
      Profile.create!(
        email: "Email",
        role_name: "Role Name",
        user_id: 2
      )
    ])
  end

  it "renders a list of profiles" do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
    assert_select cell_selector, text: Regexp.new("Email".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Role Name".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(2.to_s), count: 2
  end
end
