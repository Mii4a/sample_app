require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  
  def setup
    @user = users(:michael)
  end
  
  test "micropost interface" do
    log_in_as(@user)
    get root_path
    assert_select 'div.pagination'
    assert_select 'input[type=file]'
    # 無効な送信
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "" } }
    end
    assert_select 'div#error_explanation'
    # 有効な送信
    content = "This micropost really ties the room together"
    picture = fixture_file_upload('rails.png','image/png')
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: { content: content,
                                                   picture: picture } }
    end
    assert assigns(:micropost).picture?
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
    # 投稿を削除する
    assert_select 'a', text: "delete"
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
    # 違うユーザーのプロフィールにアクセス（削除リンクがないことを確認）
    get user_path(users(:archer))
    assert_select 'a', text: "delete", count: 0
  end
  
  test "should include current user, follower, reply user in feed" do
    from_user = users(:michael)  #followed lana and malory
    to_user   = users(:archer)   #followed michael
    other_user1 = users(:lana)   #followed michael
    other_user2 = users(:malory) #no following
    unique_name = to_user.unique_name
    content = "@#{unique_name} reply"
    # include reply when from_user
    log_in_as(from_user)
    get root_url
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: { content: content } }
    end
    micropost_id = from_user.microposts.first.id
    get root_url
    assert_select "#micropost-#{micropost_id} span.content", text: content
    # include reply when to_user
    log_in_as(to_user)
    get root_path
    assert_select "#micropost-#{micropost_id} span.content", text: content
    # include reply when from_user's follower
    log_in_as(other_user1)
    get root_path
    assert_select "#micropost-#{micropost_id} span.content", text: content
    # not include reply when a user don't follow from_user
    log_in_as(other_user2)
    get root_path
    assert_select "#micropost-#{micropost_id} span.content", text: content, count: 0
  end
  
end
