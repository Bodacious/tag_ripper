# frozen_string_literal: true

require "ripper"
require "yaml" if ENV["DEBUG"]
require_relative "tag_ripper/lexical_token"
require_relative "tag_ripper/taggable_entity"

module TagRipper
  class Ripper
    class TaggableStack < DelegateClass(Array)
      def initialize(*args)
        super(args)
      end
    end

    def initialize(code_string)
      tokens = ::Ripper.lex(code_string)
      @lexical_tokens = tokens.map do |(col, line), type, token, _|
        LexicalToken.new([col, line], type, token)
      end
    end

    def taggables
      @taggables ||= process_taggables
    end

    protected

    def process_taggables
      return_taggables = []
      @lexical_tokens.inject(TaggableEntity.new) do |current_taggable, lex|
        next_taggable = current_taggable.send_event(lex.event, lex)
        return_taggables << current_taggable if current_taggable.closed?
        next_taggable
      end
      return_taggables
    end

    private

    def debug(message)
      return unless ENV["DEBUG"]

      puts message
    end
  end
end
