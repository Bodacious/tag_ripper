# frozen_string_literal: true

require "ripper"

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

class Lex
  IGNORED_TYPES = %i[on_sp
                     on_tstring_beg
                     on_tstring_content
                     on_tstring_end
                     on_nl
                     on_ignored_nl
                     on_period].freeze

  IGNORED_TYPES_AND_TOKENS = Hash.new do |hash, key|
    hash[key] = []
  end
  IGNORED_TYPES_AND_TOKENS[:on_ident] << "private"
  IGNORED_TYPES_AND_TOKENS[:on_ident] << "require"
  NAME_IDENTIFIERS = %i[on_const on_ident].freeze

  class Location
    attr_reader :col
    attr_reader :line

    def initialize(col, line)
      @col = col
      @line = line
      freeze
    end
  end

  attr_reader :location

  attr_reader :type

  attr_reader :token

  attr_reader :state

  def initialize((col, line), type, token, state = nil)
    @location = Location.new(col, line)
    @type = type.to_sym
    @token = token.to_s
    @state = state.to_s
  end

  def comment?
    type == :on_comment
  end

  def keyword?
    type == :on_kw
  end

  def tag_comment?
    comment? && token.match?(/# @domain: (.+)/)
  end

  def non_tag_comment?
    comment? && !tag_comment?
  end

  def tag_name
    "domain"
  end

  def tag_values
    token.scan(/# @domain: (.+)/)[0]
  end

  alias tag_value tag_values

  def ignored?
    IGNORED_TYPES.include?(type) ||
      IGNORED_TYPES_AND_TOKENS[type].include?(token) ||
      non_tag_comment?
  end

  def taggable_definition?
    keyword? && token.match(/class|module|def/)
  end

  def taggable_name?
    NAME_IDENTIFIERS.include?(type)
  end

  def end?
    keyword? && token.match(/end/)
  end
end

class TagRipper
  def initialize(file_path)
    @tokens = Ripper.lex(File.read(file_path))
    @stored_taggables = []
  end

  def taggables # rubocop:disable Metrics
    @tokens.each do |(col, line), type, token, _|
      lex = Lex.new([col, line], type, token)
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
