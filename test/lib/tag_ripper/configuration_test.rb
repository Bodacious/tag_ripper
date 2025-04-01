require "test_helper"

module TagRipper
  class ConfigurationTest < Minitest::Test
    def test_configuring_the_included_tags
      skip "Move these tests into the configuration class"
      TagRipper.configure do |config|
        config.only_tags = %w[one two]
      end

      assert_includes TagRipper.config[:only_tags], "one"
      assert_includes TagRipper.config[:only_tags], "two"
    end

    def test_configuring_the_excluded_tags
      skip "Move these tests into the configuration class"
      TagRipper.configure do |config|
        config.except_tags = %w[one two]
      end

      assert_includes TagRipper.config[:except_tags], "one"
      assert_includes TagRipper.config[:except_tags], "two"
    end
  end
end
