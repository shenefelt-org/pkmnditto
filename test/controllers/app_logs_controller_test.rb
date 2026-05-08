require "test_helper"

class AppLogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @app_log = app_logs(:one)
  end

  test "should get index" do
    get app_logs_url
    assert_response :success
  end

  test "should get new" do
    get new_app_log_url
    assert_response :success
  end

  test "should create app_log" do
    assert_difference("AppLog.count") do
      post app_logs_url, params: { app_log: { ip_address: @app_log.ip_address, level: @app_log.level, message: @app_log.message, user_id: @app_log.user_id } }
    end

    assert_redirected_to app_log_url(AppLog.last)
  end

  test "should show app_log" do
    get app_log_url(@app_log)
    assert_response :success
  end

  test "should get edit" do
    get edit_app_log_url(@app_log)
    assert_response :success
  end

  test "should update app_log" do
    patch app_log_url(@app_log), params: { app_log: { ip_address: @app_log.ip_address, level: @app_log.level, message: @app_log.message, user_id: @app_log.user_id } }
    assert_redirected_to app_log_url(@app_log)
  end

  test "should destroy app_log" do
    assert_difference("AppLog.count", -1) do
      delete app_log_url(@app_log)
    end

    assert_redirected_to app_logs_url
  end
end
