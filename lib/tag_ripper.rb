# frozen_string_literal: true

require "ripper"

require_relative "tag_ripper/lexical_token"
require_relative "tag_ripper/taggable"

module TagRipper
  class Ripper
    def initialize(file_path)
      tokens = ::Ripper.lex(File.read(file_path))
      @lexical_tokens = tokens.map do |(col, line), type, token, _|
        LexicalToken.new([col, line], type, token)
      end
      @stored_taggables = []
    end

    def taggables
      @taggables ||= process_taggables
    end

    protected

    def relevant_lexical_tokens
      @lexical_tokens.reject(&:ignored?)
    end

    def process_taggables # rubocop:disable Metrics
      relevant_lexical_tokens.each do |lex|
        @current_taggable ||= Taggable.new

        if lex.tag_comment?
          @current_taggable.add_tag(lex.tag_name,
                                    lex.tag_value)
        end

        if lex.taggable_definition? && @current_taggable.named?
          @current_taggable = @current_taggable.build_child
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
