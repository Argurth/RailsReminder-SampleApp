require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "invalid signup information" do
    user_params = {
        name: "",
        email: "user@invalid",
        password: "foo",
        password_confirmation: "bar"
    }
    get signup_path
    assert_template 'users/new'
    assert_select 'form[action="/signup"]'
    assert_no_difference 'User.count' do
      post signup_path, params: { user: user_params }
    end
    user = User.new(user_params)
    user.valid?
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors'
    assert_select 'div.alert.alert-danger', "The form contains 4 errors."
    user.errors.full_messages.each do |e|
      assert_select "div#error_explanation ul li", e
    end
  end

  test "valid signup information with account activation" do
    get signup_path
    user_params = {
        name: "Example User",
        email: "user@example.com",
        password: "password",
        password_confirmation: "password"
    }
    assert_difference 'User.count', 1 do
      post users_path, params: { user: user_params }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    # Try to log in before activation.
    log_in_as(user)
    assert_not is_logged_in?
    # Invalid activation token
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?
    # Valid token, wrong email
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?
    # Valid activation token
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
    assert_not flash.empty?
    assert flash["success"]
    assert_not flash["danger"]
    assert_not flash["warning"]
    assert_select 'div.alert.alert-success', flash["success"]
  end
end
