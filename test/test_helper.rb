# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "bundler"
Bundler.setup(:default, :test)
require "minitest/autorun"
require "tag_ripper"

module CustomAssertions
  refine Minitest::Assertions do
    def assert_includes_subhash(superhash, subhash, message = nil)
      assert_operator superhash, :>=, subhash, message
    end
  end
end
