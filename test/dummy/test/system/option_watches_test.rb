require "application_system_test_case"

class OptionWatchesTest < ApplicationSystemTestCase
  setup do
    @option_watch = option_watches(:one)
  end

  test "visiting the index" do
    visit option_watches_url
    assert_selector "h1", text: "Option Watches"
  end

  test "creating a Option watch" do
    visit option_watches_url
    click_on "New Option Watch"

    click_on "Create Option watch"

    assert_text "Option watch was successfully created"
    click_on "Back"
  end

  test "updating a Option watch" do
    visit option_watches_url
    click_on "Edit", match: :first

    click_on "Update Option watch"

    assert_text "Option watch was successfully updated"
    click_on "Back"
  end

  test "destroying a Option watch" do
    visit option_watches_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Option watch was successfully destroyed"
  end
end
