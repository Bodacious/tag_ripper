# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "bundler"

##
# Test suite setup
require "minitest/autorun"
require "mocha/minitest"
require "simplecov"
SimpleCov.start do
  add_filter "/test/"
  add_filter "/pkg/"
  add_filter "/samples/"
end

##
# Test helpers etc.
require "support/assertions"
require "support/extensions"
require "support/factories"
