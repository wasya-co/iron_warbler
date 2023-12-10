require 'rails_helper'

RSpec.describe "profiles/new", type: :view do
  before(:each) do
    assign(:profile, Profile.new(
      email: "MyString",
      role_name: "MyString",
      user_id: 1
    ))
  end

  it "renders new profile form" do
    render

    assert_select "form[action=?][method=?]", profiles_path, "post" do

      assert_select "input[name=?]", "profile[email]"

      assert_select "input[name=?]", "profile[role_name]"

      assert_select "input[name=?]", "profile[user_id]"
    end
  end
end
