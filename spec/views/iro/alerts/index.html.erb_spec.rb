require 'rails_helper'

RSpec.describe "alerts/index", type: :view do
  before(:each) do
    assign(:alerts, [
      Alert.create!(
        class_name: "Class Name",
        kind: "Kind",
        symbol: "Symbol",
        direction: "Direction",
        strike: 2.5,
        profile_id: 3
      ),
      Alert.create!(
        class_name: "Class Name",
        kind: "Kind",
        symbol: "Symbol",
        direction: "Direction",
        strike: 2.5,
        profile_id: 3
      )
    ])
  end

  it "renders a list of alerts" do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
    assert_select cell_selector, text: Regexp.new("Class Name".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Kind".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Symbol".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Direction".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(2.5.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(3.to_s), count: 2
  end
end
