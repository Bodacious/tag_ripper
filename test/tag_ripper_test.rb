# frozen_string_literal: true

require "test_helper"
require "tag_ripper"
class TagRipperTest < Minitest::Test
  using CustomAssertions
  def test_returns_a_list_of_taggables
    tag_ripper = TagRipper::Ripper.new(Tempfile.new)

    assert_empty tag_ripper.taggables
  end

  def test_detects_tag_comment_on_module
    tag_ripper = TagRipper::Ripper.new("./test/fixtures/simple_example.rb")

    taggable = tag_ripper.taggables.find { |t| t.name == "Foo" }

    assert_equal "Foo", taggable.name
    assert_includes_subhash taggable.tags, "domain" => ["FooDomain"]
  end
end
