# frozen_string_literal: true

require "some_file"

# Foo module
#
# @domain: FooDomain
module Foo
  # @meta_name: singleton
  class << self
    # @foo: bar
    def method_a
      # noop
    end
  end

  # @fizz: buzz
  def method_b
    # noop
  end
end
