# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "bundler"

##
# Test suite setup
Bundler.require(:default, :test)

##
# Test helpers etc.
require "support/assertions"
require "support/extensions"
require "support/factories"
