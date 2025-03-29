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
  end
end
