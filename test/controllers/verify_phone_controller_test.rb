require "test_helper"

class VerifyPhoneControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get verify_phone_create_url
    assert_response :success
  end
end
