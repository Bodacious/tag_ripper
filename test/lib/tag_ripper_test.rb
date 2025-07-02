# frozen_string_literal: true

require "test_helper"
require "tag_ripper"
class TagRipperTest < Minitest::Test
  using Assertions

  def setup; end

  def teardown
    TagRipper.reset_configuration!
  end

  def test_reset_configuration_replaces_configuration_with_new_blank_config
    TagRipper.configure do |config|
      config.only_tags = %w[foo bar]
    end

    assert_includes TagRipper.configuration.only_tags, "foo"
    assert_includes TagRipper.configuration.only_tags, "bar"

    TagRipper.reset_configuration!

    assert_empty TagRipper.configuration.only_tags
  end

  def test_returns_a_list_of_taggables
    tag_ripper = TagRipper::Ripper.new(Tempfile.new)

    assert_empty tag_ripper.taggables
  end

  def test_returns_a_list_of_taggable_modules
    tag_ripper = TagRipper::Ripper.new(Tempfile.new)

    assert_empty tag_ripper.taggable_modules
  end

  def test_returns_a_list_of_taggable_modules_detected_in_code
    tag_ripper = TagRipper::Ripper.new(<<~RUBY)
      class FooClass
      end
      module BarModule
      end
    RUBY

    taggable_modules = tag_ripper.taggable_modules

    assert_equal 2, taggable_modules.length
    assert_includes taggable_modules.map(&:name), "BarModule"
    assert_includes taggable_modules.map(&:name), "FooClass"
  end

  def test_detects_tag_comment_on_module
    code_string = File.read("./test/fixtures/simple_example.rb")
    tag_ripper = TagRipper::Ripper.new(code_string)

    taggable = tag_ripper.taggables.find { |t| t.name == "Foo" }

    assert_equal "Foo", taggable.name
    assert_includes taggable.tags["domain"], "FooDomain"
  end

  def test_detects_tag_comment_on_class_nested_in_module
    code_string = File.read("./test/fixtures/nested_example.rb")
    tag_ripper = TagRipper::Ripper.new(code_string)

    taggable = tag_ripper.taggables.find { |t| t.name == "Bar" }

    assert_equal "Bar", taggable.name
    assert_includes taggable.tags["domain"], "FooDomain"
  end

  def test_detects_tag_comment_on_class_with_superclass
    tag_ripper = TagRipper::Ripper.new(<<~RUBY)
      module FooDomain
        # @domain: FooDomain
        class Foo < Bar
        end
      end
    RUBY

    taggable = tag_ripper.taggables.find { |t| t.name == "Foo" }

    assert_equal "Foo", taggable.name
    assert_equal "FooDomain::Foo", taggable.fqn
    assert_includes taggable.tags["domain"], "FooDomain"
  end

  def test_detects_tag_comment_on_class_with_namespace_nesting
    code_string = File.read("./test/fixtures/namespace_nested_example.rb")
    tag_ripper = TagRipper::Ripper.new(code_string)

    taggable = tag_ripper.taggables.find { |t| t.name == "Foo::Bar" }

    assert_equal "Foo::Bar", taggable.name
    assert_includes taggable.tags["domain"], "FooDomain"
  end

  def test_detects_modules_with_multiple_tags
    code_string = File.read("./test/fixtures/complex_example.rb")
    tag_ripper = TagRipper::Ripper.new(code_string)

    taggable = tag_ripper.taggables.find { |t| t.name == "Foo" }

    assert_equal "Foo", taggable.name
    assert_includes taggable.tags["domain"], "Fizz"
    assert_includes taggable.tags["domain"], "Buzz"
  end

  def test_detects_tags_on_public_methods
    code_string = File.read("./test/fixtures/complex_example.rb")
    tag_ripper = TagRipper::Ripper.new(code_string)

    taggable = tag_ripper.taggables.find { |t| t.name == "method_a" }

    assert_includes taggable.tags["domain"], "Method"
  end

  def test_detects_tags_on_singleton_class_example
    code_string = File.read("./test/fixtures/singleton_class.rb")
    tag_ripper = TagRipper::Ripper.new(code_string)

    taggable = tag_ripper.taggables.find { |t| t.name == "self" }

    assert_equal :class, taggable.type
    assert_includes taggable.tags["meta_name"], "singleton"
  end
end
