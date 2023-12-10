require 'rails_helper'

RSpec.describe "alerts/new", type: :view do
  before(:each) do
    assign(:alert, Alert.new(
      class_name: "MyString",
      kind: "MyString",
      symbol: "MyString",
      direction: "MyString",
      strike: 1.5,
      profile_id: 1
    ))
  end

  it "renders new alert form" do
    render

    assert_select "form[action=?][method=?]", alerts_path, "post" do

      assert_select "input[name=?]", "alert[class_name]"

      assert_select "input[name=?]", "alert[kind]"

      assert_select "input[name=?]", "alert[symbol]"

      assert_select "input[name=?]", "alert[direction]"

      assert_select "input[name=?]", "alert[strike]"

      assert_select "input[name=?]", "alert[profile_id]"
    end
  end
end
