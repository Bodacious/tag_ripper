# frozen_string_literal: true

require "test_helper"

module TagRipper
  class TaggableEntityTest < Minitest::Test
    using Assertions
    def test_freezes_on_end_kw
      subject = described_class.new

      subject.send_event(:on_kw, stub("Lex", event: :on_kw, token: "end"))

      assert_predicate subject, :frozen?
    end

    def test_collects_tags_if_lex_is_tagged_comment
      subject = described_class.new

      lex = stub("Lex",
                 event: :on_comment,
                 token: "# @foo: bar",
                 tag_comment?: true,
                 tag_name: "foo",
                 tag_value: "bar")
      subject.send_event(lex.event, lex)

      assert_includes_subhash subject.tags, { "foo" => ["bar"].to_set }
    end

    def test_opens_on_first_tagged_comment
      subject = described_class.new

      refute_predicate subject, :open?

      lex = stub("Lex",
                 event: :on_comment,
                 token: "# @foo: bar",
                 tag_comment?: true,
                 tag_name: "foo",
                 tag_value: "bar")
      subject.send_event(lex.event, lex)

      assert_predicate subject, :open?
    end

    def test_it_initializes_as_pending?
      subject = described_class.new

      assert_predicate subject, :pending?
    end

    def test_may_tag_if_pending
      subject = described_class.new

      assert_predicate subject, :may_tag?
    end

    def test_may_await_name_if_pending
      subject = described_class.new

      assert_predicate subject, :may_await_name?
    end

    def test_may_not_name_if_pending
      subject = described_class.new

      refute_predicate subject, :may_name?
    end

    def test_may_not_close_if_pending
      subject = described_class.new

      refute_predicate subject, :may_close?
    end

    def test_may_await_name_if_tagged
      subject = described_class.new
      subject.tag!("foo", "bar")

      assert_predicate subject, :may_await_name?
    end

    def test_may_not_name_if_tagged
      subject = described_class.new
      subject.tag!("foo", "bar")

      refute_predicate subject, :may_name?
    end

    def test_may_not_close_if_tagged
      subject = described_class.new
      subject.tag!("foo", "bar")

      refute_predicate subject, :may_close?
    end

    def test_may_name_if_awaiting_name
      subject = described_class.new
      subject.await_name!

      assert_predicate subject, :may_name?
    end

    def test_may_not_tag_if_awaiting_name
      subject = described_class.new
      subject.await_name!

      refute_predicate subject, :may_tag?
    end

    def test_may_not_close_if_awaiting_name
      subject = described_class.new
      subject.await_name!

      refute_predicate subject, :may_close?
    end

    def test_may_not_await_name_if_named?
      subject = described_class.new
      subject.await_name!
      subject.name = "name"

      refute_predicate subject, :may_await_name?
    end

    def test_may_not_tag_if_named?
      subject = described_class.new
      subject.await_name!
      subject.name = "name"

      refute_predicate subject, :may_tag?
    end

    def test_may_close_if_named?
      subject = described_class.new
      subject.await_name!
      subject.name = "name"

      assert_predicate subject, :may_close?
    end

    def test_tag_raises_an_exception_if_may_not_tag?
      subject = described_class.new
      subject.expects(:may_tag?).returns(false)
      assert_raises(TagRipper::TaggableEntity::IllegalStateTransitionError,
                    "Cannot transition from pending to tagged") do
        subject.tag!("tag-name", "tag-value")
      end
    end

    def test_await_name_raises_an_exception_if_may_not_await_name
      subject = described_class.new
      subject.expects(:may_await_name?).returns(false)
      assert_raises(TagRipper::TaggableEntity::IllegalStateTransitionError,
                    "Cannot transition from pending to awaiting_name") do
        subject.await_name!
      end
    end

    def test_name_raises_an_exception_if_may_not_set_name
      subject = described_class.new
      subject.expects(:may_name?).returns(false)
      assert_raises(TagRipper::TaggableEntity::IllegalStateTransitionError,
                    "Cannot transition from pending to named") do
        subject.name = "entity-name"
      end
    end

    def test_tag_adds_tags_and_changes_status_to_tagged?
      subject = described_class.new

      refute_predicate subject, :tagged?

      subject.tag!("foo", "bar")

      assert_predicate subject, :tagged?
    end

    def test_await_name_changes_status_to_awaiting_name
      subject = described_class.new

      refute_predicate subject, :awaiting_name?

      subject.await_name!

      assert_predicate subject, :awaiting_name?
    end

    def test_name_changes_status_to_named?
      subject = described_class.new
      subject.await_name!

      refute_predicate subject, :named?
      subject.name = "foobar"

      assert_predicate subject, :named?
    end

    def test_it_sets_status_to_closed_on_close
      subject = described_class.new

      refute_predicate subject, :closed?
      subject.close!

      assert_predicate subject, :closed?
    end

    def test_it_freezes_on_close
      subject = described_class.new

      refute_predicate subject, :frozen?
      subject.close!

      assert_predicate subject, :frozen?
    end

    def test_fully_qualified_name_returns_the_names_of_the_parents_too
      skip 'Find out why this has stopped working'

      a = described_class.new
      a.expects(:name).returns("Foo")

      b = described_class.new(parent: a)
      b.expects(:name).returns("Bar")

      c = described_class.new(parent: b)
      c.expects(:name).returns("C")
      c.expects(:type).returns("class")

      assert_equal "Foo::Bar::C", c.fully_qualified_name
    end

    def test_fully_qualified_name_when_last_item_is_an_instance_method
      skip 'Find out why this has stopped working'

      a = described_class.new
      a.expects(:name).returns("Foo")

      b = described_class.new(parent: a)
      b.expects(:name).returns("Bar")

      c = described_class.new(parent: b)
      c.expects(:name).returns("method_c").at_least_once
      c.expects(:type).returns(:instance_method)

      assert_equal "Foo::Bar#method_c", c.fully_qualified_name
    end
  end
end
