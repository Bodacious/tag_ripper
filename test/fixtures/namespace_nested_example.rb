# frozen_string_literal: true

require "some_file"

##
# Foo module
#
module Foo;end

##
# Bar class
# @domain: FooDomain
class Foo::Bar
  def method_a; end

  def method_b; end
end
