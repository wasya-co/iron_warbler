require 'rails_helper'

RSpec.describe "alerts/edit", type: :view do
  let(:alert) {
    Alert.create!(
      class_name: "MyString",
      kind: "MyString",
      symbol: "MyString",
      direction: "MyString",
      strike: 1.5,
      profile_id: 1
    )
  }

  before(:each) do
    assign(:alert, alert)
  end

  it "renders the edit alert form" do
    render

    assert_select "form[action=?][method=?]", alert_path(alert), "post" do

      assert_select "input[name=?]", "alert[class_name]"

      assert_select "input[name=?]", "alert[kind]"

      assert_select "input[name=?]", "alert[symbol]"

      assert_select "input[name=?]", "alert[direction]"

      assert_select "input[name=?]", "alert[strike]"

      assert_select "input[name=?]", "alert[profile_id]"
    end
  end
end
