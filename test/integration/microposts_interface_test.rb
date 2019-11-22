# frozen_string_literal: true

require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test 'micropost interface' do
    log_in_as(@user)
    get root_path
    assert_select 'div.pagination'
    # Invalid submission
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: '' } }
    end
    assert_select 'div#error_explanation'
    # Valid submission
    content = 'This micropost really ties the room together'
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: { content: content } }
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
    # Delete post
    assert_select 'a', text: 'delete'
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
    # Visit different user (no delete links)
    get user_path(users(:archer))
    assert_select 'a', text: 'delete', count: 0
  end

  # template for sidebar test
  # test 'micropost sidebar count' do
  #   log_in_as(@user)
  #   get root_path
  #   assert_match "#{FILL_IN} microposts", response.body
  #   # User with zero microposts
  #   other_user = users(:malory)
  #   log_in_as(other_user)
  #   get root_path
  #   assert_match '0 microposts', response.body
  #   other_user.microposts.create!(content: 'A micropost')
  #   get root_path
  #   assert_match FILL_IN, response.body
  # end

  # add an image upload test template
  # test "micropost interface" do
  #   log_in_as(@user)
  #   get root_path
  #   assert_select 'div.pagination'
  #   assert_select 'input[type=FILL_IN]'
  #   # Invalid submission
  #   post microposts_path, params: { micropost: { content: "" } }
  #   assert_select 'div#error_explanation'
  #   # Valid submission
  #   content = "This micropost really ties the room together"
  #   picture = fixture_file_upload('test/fixtures/rails.png', 'image/png')
  #   assert_difference 'Micropost.count', 1 do
  #     post microposts_path, params: { micropost:
  #                                     { content: content,
  #                                       picture: FILL_IN } }
  #   end
  #   assert FILL_IN.picture?
  #   follow_redirect!
  #   assert_match content, response.body
  #   # Delete a post.
  #   assert_select 'a', 'delete'
  #   first_micropost = @user.microposts.paginate(page: 1).first
  #   assert_difference 'Micropost.count', -1 do
  #     delete micropost_path(first_micropost)
  #   end
  #   # Visit a different user.
  #   get user_path(users(:archer))
  #   assert_select 'a', { text: 'delete', count: 0 }
  # end
end
