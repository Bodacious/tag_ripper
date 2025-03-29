# frozen_string_literal: true

require "minitest/autorun"

module TagRipper
  class LexicalTokenTest < Minitest::Test
    def test_extracts_col_from_input_array
      subject = described_class.new([2, 3], "foo", "bar")

      assert_equal 2, subject.col
    end

    def test_extracts_line_from_input_array
      subject = described_class.new([2, 3], "foo", "bar")

      assert_equal 3, subject.line
    end

    def test_type_returns_the_type_as_a_symbol
      subject = described_class.new([0, 0], "foo", "bar")

      assert_equal :foo, subject.type
    end

    def test_token_returns_the_token_as_a_string
      subject = described_class.new([0, 0], "foo", :bar)

      assert_equal "bar", subject.token
    end

    def test_comment_predicate_returns_true_if_comment
      subject = described_class.new([0, 0], :on_comment, "")

      assert_predicate subject, :comment?
    end

    def test_comment_predicate_returns_false_if_not_comment
      subject = described_class.new([0, 0], :on_kw, "")

      refute_predicate subject, :comment?
    end

    def test_end_predicate_returns_true_if_end
      subject = described_class.new([0, 0], :on_kw, "end")

      assert_predicate subject, :end?
    end

    def test_end_predicate_returns_false_if_not_end
      subject = described_class.new([0, 0], :on_kw, "")

      refute_predicate subject, :comment?
    end

    def test_to_s_returns_the_token
      subject = described_class.new([0, 0], :on_kw, "end")

      assert_equal "end", subject.to_s
    end

    def test_event_returns_the_type
      subject = described_class.new([0, 0], :on_kw, "end")

      assert_equal :on_kw, subject.event
    end

    def test_tag_name_returns_the_tag_name_as_a_string
      subject = described_class.new([0, 0], :on_comment, "# @foo: bar")

      assert_equal "foo", subject.tag_name
    end

    def test_tag_value_returns_the_tag_value_as_a_string
      subject = described_class.new([0, 0], :on_comment, "# @foo: bar")

      assert_equal "bar", subject.tag_value
    end

    def test_tag_comment_returns_false_if_comment_without_tag
      subject = described_class.new([0, 0], :on_comment, "# foo: bar")

      refute_predicate subject, :tag_comment?
    end

    def test_tag_comment_returns_true_if_comment_without_tag
      subject = described_class.new([0, 0], :on_comment, "# @fizz: buzz")

      assert_predicate subject, :tag_comment?
    end
  end
end
