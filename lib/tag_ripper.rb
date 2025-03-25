# frozen_string_literal: true

require "ripper"

require_relative "tag_ripper/lexical_token"

module TagRipper
  class Ripper
    def initialize(file_path)
      @tokens = ::Ripper.lex(File.read(file_path))
      @stored_taggables = []
    end

    def taggables
      @taggables ||= process_taggables
    end

    protected

    def process_taggables # rubocop:disable Metrics
      @tokens.each do |(col, line), type, token, _|
        lex = LexicalToken.new([col, line], type, token)
        next if lex.ignored?

        @current_taggable ||= Taggable.new
        @current_taggable.add_tag(lex.tag_name, lex.tag_value) if lex.tag_comment?
        if lex.taggable_definition? && @current_taggable.named?
          @current_taggable = Taggable.new(parent: @current_taggable)
        elsif lex.taggable_definition?
          @current_taggable.open
        end

        @current_taggable.name_from_lex(lex) if lex.taggable_name?

        next unless lex.end?
        raise "Can't close nil scope" unless @current_taggable

        @current_taggable.end!
        @stored_taggables << @current_taggable
        @current_taggable = @current_taggable.parent
      end
      @stored_taggables
    end
  end
end
class Taggable
  def initialize(name: nil, parent: nil)
    @name = name
    @tags = Hash.new { |hash, key| hash[key] = [] }
    @ended = false
    @parent = parent
    @type = nil
    @open = false
  end

  def inspect
    "<id=#{object_id},@name=#{@name},tags=#{@tags}>"
  end

  def named?
    !!@name
  end

  def name
    @name.to_s.dup
  end

  def add_tag(name, value)
    @tags[name] = value
  end

  def name_from_lex(lex)
    @name = lex.token
    @type = lex.type
  end

  attr_reader :tags
  attr_reader :parent

  def name=(name)
    @name = name.to_s
  end

  def type=(type)
    @type = type.to_sym
  end

  def blank?
    name.empty? && tags.empty?
  end

  def open?
    @open
  end

  def ended?
    @ended
  end

  def end!
    @open = false
    @ended = true
  end

  def open
    @open = true
  end

  def state
    return "ended" if ended?
    return "blank" if blank?
    return "tagged" if tags.any?
    return "awaiting_name" if open? && !named?

    "open"
  end
end



