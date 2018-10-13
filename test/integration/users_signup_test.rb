require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
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
    user.errors.full_messages.each do |e|
      assert_select "div#error_explanation ul li", e
    end
  end

  test "valid signup information" do
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
    follow_redirect!
    assert_template 'users/show'
    assert_not flash.empty?
    assert flash["success"]
    assert_not flash["error"]
    assert_not flash["warning"]
    assert_select 'div.alert.alert-success', flash["success"]
  end
end
