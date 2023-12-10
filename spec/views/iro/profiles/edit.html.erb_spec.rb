require 'rails_helper'

RSpec.describe "profiles/edit", type: :view do
  let(:profile) {
    Profile.create!(
      email: "MyString",
      role_name: "MyString",
      user_id: 1
    )
  }

  before(:each) do
    assign(:profile, profile)
  end

  it "renders the edit profile form" do
    render

    assert_select "form[action=?][method=?]", profile_path(profile), "post" do

      assert_select "input[name=?]", "profile[email]"

      assert_select "input[name=?]", "profile[role_name]"

      assert_select "input[name=?]", "profile[user_id]"
    end
  end
end
