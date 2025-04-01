require "test_helper"

module TagRipper
  class ConfigurationTest < Minitest::Test
    def test_only_tags_is_empty_by_default
      subject = described_class.new

      assert_empty subject.only_tags
    end

    def test_except_tags_is_empty_by_default
      subject = described_class.new

      assert_empty subject.except_tags
    end
    def test_configuration_can_be_set_via_a_block
      subject = described_class.new
      subject.eval_config do |config|
        config.only_tags = %w[one two]
      end

      assert_includes subject.only_tags, "one"
      assert_includes subject.only_tags, "two"
    end
  end
end
