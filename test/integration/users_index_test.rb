require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  require 'test_helper'

  class UsersIndexTest < ActionDispatch::IntegrationTest
    def setup
      @admin = users(:michael)
      @non_admin = users(:archer)
      @non_activated = users(:lana)
    end

    test "index including pagination and delete link" do
      assert @admin.admin?
      log_in_as(@admin)
      get users_path
      assert_template 'users/index'
      assert_select 'div.pagination', count: 2
      User.where(activated: true).paginate(page: 1).each do |user|
        assert_select 'a[href=?]', user_path(user), text: user.name
        if user == @admin
          assert_select 'a[href=?][data-method="delete"]', user_path(user), text: "delete", count: 0
        else
          assert_select 'a[href=?][data-method="delete"]', user_path(user), text: "delete"
        end
      end
      assert_difference 'User.count', -1 do
        delete user_path(@non_admin)
      end
    end

    test "index including as non-admin" do
      log_in_as(@non_admin)
      assert_not @non_admin.admin?
      get users_path
      assert_template 'users/index'
      assert_select 'div.pagination', count: 2
      User.where(activated: true).paginate(page: 1).each do |user|
        assert_select 'a[href=?]', user_path(user), text: user.name
        assert_select 'a[href=?][data-method="delete"]', user_path(user), text: "delete", count: 0
      end
      assert_no_difference 'User.count' do
        delete user_path(@admin)
      end
    end
  end
end
