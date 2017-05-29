require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end
  
  test "layout links" do
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", signup_path
    
    #check that users must be logged in to visit parts of site
    get users_path
    assert_redirected_to login_path
    
    get edit_user_path(@user)
    assert_redirected_to login_path
    
    patch user_path(@other_user), params: { user: { name:  "",
                                              email: "foo@invalid",
                                              password:              "foo",
                                              password_confirmation: "bar" } }
    assert_redirected_to login_path
    
    #check that logged in user can only access what they are supposed to
    log_in_as(@user)
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2 #home
    assert_select "a[href=?]", help_path          #help
    assert_select "a[href=?]", about_path         # about
    assert_select "a[href=?]", contact_path       # contace
    assert_select "a[href=?]", signup_path        # signup
    assert_select "a[href=?]", users_path         # List users
    assert_select "a[href=?]", user_path(@user)   # show user
    assert_select "a[href=?]", edit_user_path(@user) # Settings
    get edit_user_path(@other_user)
    assert_redirected_to root_url
    patch user_path(@other_user), params: { user: { name:  "",
                                              email: "foo@invalid",
                                              password:              "foo",
                                              password_confirmation: "bar" } }
    assert_redirected_to root_url
    
  end
end
