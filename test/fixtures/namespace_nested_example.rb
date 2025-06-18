# frozen_string_literal: true

require "some_file"

##
# Foo module
#
module Foo; end

##
# Bar class
# @domain: FooDomain
module Foo
  class Bar
    def method_a; end

    def method_b; end
  end
end
