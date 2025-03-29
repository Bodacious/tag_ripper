# frozen_string_literal: true

require "ripper"
require_relative "tag_ripper/lexical_token"
require_relative "tag_ripper/taggable_entity"
require_relative "tag_ripper/configuration"

module TagRipper
  class << self

    def configure(&)
      configuration.eval_config(&)
    end

    def configuration
      @configuration ||= Configuration.new
    end
    alias config configuration
  end

  class Ripper
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
  end
end
