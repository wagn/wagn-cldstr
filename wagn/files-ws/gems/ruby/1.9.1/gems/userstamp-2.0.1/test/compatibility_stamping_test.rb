require 'test/helper'

class CompatibilityStampingTests < Test::Unit::TestCase  # :nodoc:
  def setup
    create_test_models
    Ddb::Userstamp.compatibility_mode = true
    require 'test/models/comment'
    Comment.delete_all
    @first_comment = Comment.create!(:comment => 'a comment', :post => @first_post)
  end

  def test_comment_creation_with_stamped_integer
    Person.stamper = @nicole.id
    assert_equal @nicole.id, Person.stamper

    comment = Comment.create(:comment => "Test Comment - 2")
    assert_equal @nicole.id, comment.created_by
    assert_equal @nicole.id, comment.updated_by
    assert_equal @nicole, comment.creator
    assert_equal @nicole, comment.updater
  end

  def test_comment_creation_with_stamped_integer
    Person.stamper = @nicole.id
    assert_equal @nicole.id, Person.stamper

    comment = Comment.create(:comment => "Test Comment - 2")
    assert_equal @nicole.id, comment.created_by
    assert_equal @nicole.id, comment.updated_by
    assert_equal @nicole, comment.creator
    assert_equal @nicole, comment.updater
  end

  def test_comment_creation_with_stamped_object
    assert_equal @delynn.id, Person.stamper

    comment = Comment.create(:comment => "Test Comment")
    assert_equal @delynn.id, comment.created_by
    assert_equal @delynn.id, comment.updated_by
    assert_equal @delynn, comment.creator
    assert_equal @delynn, comment.updater
  end
  
  def test_comment_updating_with_stamped_object
    Person.stamper = @nicole
    assert_equal @nicole.id, Person.stamper

    @first_comment.comment << " - Updated"
    @first_comment.save
    @first_comment.reload
    assert_equal @delynn.id, @first_comment.created_by
    assert_equal @nicole.id, @first_comment.updated_by
    assert_equal @delynn, @first_comment.creator
    assert_equal @nicole, @first_comment.updater
  end

  def test_comment_updating_with_stamped_integer
    Person.stamper = @nicole.id
    assert_equal @nicole.id, Person.stamper

    @first_comment.comment << " - Updated"
    @first_comment.save
    @first_comment.reload
    assert_equal @delynn.id, @first_comment.created_by
    assert_equal @nicole.id, @first_comment.updated_by
    assert_equal @delynn, @first_comment.creator
    assert_equal @nicole, @first_comment.updater
  end
end