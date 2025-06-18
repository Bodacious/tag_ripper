# frozen_string_literal: true

# @module: Tracer
module Tracer
  # @singleton: Enable
  def self.enable
    trace = TracePoint.new(:call, :return) do |tp|
      puts "[TRACE] #{tp.event} #{tp.defined_class}##{tp.method_id}"
    end
    trace.enable
  end
end

module RefinementExample
  refine String do
    def shoutify
      "#{upcase}!!!"
    end
  end
end

class Metamagic
  prepend(Module.new do
    def initialize(*)
      super
      puts "[PREPENDED] #{self.class} instance created"
    end
  end)

  def initialize(data = [])
    @data = data.lazy.map { |x| x * 2 }
  end

  # @method: respond_to_missing?
  def respond_to_missing?(name, _)
    name.to_s.start_with?("get_")
  end

  def method_missing(name, *args)
    if name.to_s.start_with?("get_")
      key = name.to_s.sub("get_", "").to_sym
      @data.find { |h| h.is_a?(Hash) && h.key?(key) }&.[](key)
    else
      super
    end
  end

  class_eval do
    define_method(:dynamic_greet) do |name|
      "Hail, #{name}."
    end
  end

  def create_generator(limit = 5)
    Enumerator.new do |y|
      x = 0
      loop do
        y << (x += 1)
        break if x >= limit
      end
    end
  end
end

##
# This module is defined after the main module is closed
# @name: outlier
module Outlier
end
# Singleton class hackery
obj = Metamagic.new([{ foo: 42 }, { bar: 99 }])

# @test: pilot
class << obj
  define_method(:singleton_magic) { "I live only here" }
end

# Trace example
Tracer.enable

# Using the class
puts obj.dynamic_greet("wizard")
puts obj.get_foo
puts obj.singleton_magic

# Refinements
using RefinementExample
puts "hello".shoutify

# Lazy enumeration
gen = obj.create_generator(3)
puts gen.map { |x| x * 10 }.to_a.inspect
