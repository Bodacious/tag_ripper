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

  def test_detects_tag_comment_on_class_nested_in_module
    tag_ripper = TagRipper::Ripper.new("./test/fixtures/nested_example.rb")

    taggable = tag_ripper.taggables.find { |t| t.name == "Bar" }

    assert_equal "Bar", taggable.name
    assert_includes_subhash taggable.tags, "domain" => ["FooDomain"]
  end
  def test_detects_modules_with_multiple_tags
    tag_ripper = TagRipper::Ripper.new("./test/fixtures/complex_example.rb")

    puts tag_ripper.taggables.inspect
    taggable = tag_ripper.taggables.find { |t| t.name == "Foo" }

    assert_equal "Foo", taggable.name
    assert_includes_subhash taggable.tags, "domain" => ["Fizz", "Buzz"]
  end

end
