require 'rails_helper'

RSpec.describe "alerts/show", type: :view do
  before(:each) do
    assign(:alert, Alert.create!(
      class_name: "Class Name",
      kind: "Kind",
      symbol: "Symbol",
      direction: "Direction",
      strike: 2.5,
      profile_id: 3
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Class Name/)
    expect(rendered).to match(/Kind/)
    expect(rendered).to match(/Symbol/)
    expect(rendered).to match(/Direction/)
    expect(rendered).to match(/2.5/)
    expect(rendered).to match(/3/)
  end
end
