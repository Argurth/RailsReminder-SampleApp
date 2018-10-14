require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    user_params = {
        name: "",
        email: "foo@invalid",
        password: "foo",
        password_confirmation: "bar"
    }
    patch user_path(@user), params: { user: user_params }

    assert_template 'users/edit'
    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors'
    assert_select 'div.alert.alert-danger', "The form contains 4 errors."
    user = User.new(user_params)
    user.errors.full_messages.each do |e|
      assert_select "div#error_explanation ul li", e
    end
  end

  test "successful edit without password" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    user_params = {
        name: "Foo Bar",
        email: "foo@bar.com",
        password: "",
        password_confirmation: ""
    }
    patch user_path(@user), params: { user: user_params }

    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_not flash.empty?
    assert flash["success"]
    assert_not flash["danger"]
    assert_not flash["warning"]
    assert_select 'div.alert.alert-success', flash["success"]

    @user.reload
    assert_equal user_params[:name], @user.name
    assert_equal user_params[:email], @user.email
    assert @user.authenticate("password")
  end

  test "successful edit with password" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    user_params = {
        name: "Foo Bar",
        email: "foo@bar.com",
        password: "new_password",
        password_confirmation: "new_password"
    }
    patch user_path(@user), params: { user: user_params }

    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_not flash.empty?
    assert flash["success"]
    assert_not flash["danger"]
    assert_not flash["warning"]
    assert_select 'div.alert.alert-success', flash["success"]

    @user.reload
    assert_equal user_params[:name], @user.name
    assert_equal user_params[:email], @user.email
    assert @user.authenticate("new_password")
    assert_not @user.authenticate("password")
  end

  test "should redirect edit when not logged in" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_not flash["success"]
    assert flash["danger"]
    assert_not flash["warning"]
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch user_path(@user), params: {
        user: {
            name: @user.name,
            email: @user.email
        }
    }
    assert_not flash.empty?
    assert_not flash["success"]
    assert flash["danger"]
    assert_not flash["warning"]
    assert_redirected_to login_url
  end

  test "should redirect edit when logged in as wrong user" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect update when logged in as wrong user" do
    log_in_as(@other_user)
    patch user_path(@user), params: {
        user: {
            name: @user.name,
            email: @user.email
        }
    }
    assert flash.empty?
    assert_redirected_to root_url
  end
end
