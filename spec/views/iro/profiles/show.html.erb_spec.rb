require 'rails_helper'

RSpec.describe "profiles/show", type: :view do
  before(:each) do
    assign(:profile, Profile.create!(
      email: "Email",
      role_name: "Role Name",
      user_id: 2
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Email/)
    expect(rendered).to match(/Role Name/)
    expect(rendered).to match(/2/)
  end
end
