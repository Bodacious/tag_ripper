# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "bundler"
Bundler.setup(:default, :test)
require "minitest/autorun"
require "tag_ripper"
require "mocha/minitest"
require "support/assertions"
require "support/extensions"
