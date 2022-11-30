require "test_helper"

class OptionWatchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @option_watch = option_watches(:one)
  end

  test "should get index" do
    get option_watches_url
    assert_response :success
  end

  test "should get new" do
    get new_option_watch_url
    assert_response :success
  end

  test "should create option_watch" do
    assert_difference('OptionWatch.count') do
      post option_watches_url, params: { option_watch: {  } }
    end

    assert_redirected_to option_watch_url(OptionWatch.last)
  end

  test "should show option_watch" do
    get option_watch_url(@option_watch)
    assert_response :success
  end

  test "should get edit" do
    get edit_option_watch_url(@option_watch)
    assert_response :success
  end

  test "should update option_watch" do
    patch option_watch_url(@option_watch), params: { option_watch: {  } }
    assert_redirected_to option_watch_url(@option_watch)
  end

  test "should destroy option_watch" do
    assert_difference('OptionWatch.count', -1) do
      delete option_watch_url(@option_watch)
    end

    assert_redirected_to option_watches_url
  end
end
