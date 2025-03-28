# frozen_string_literal: true

require "ripper"
require "yaml" if ENV["DEBUG"]
require_relative "tag_ripper/lexical_token"
require_relative "tag_ripper/taggable"

module TagRipper
  class Ripper
    class TaggableStack < DelegateClass(Array)
      def initialize(*args)
        super(args)
      end
    end

    def initialize(file_path)
      tokens = ::Ripper.lex(File.read(file_path))
      @lexical_tokens = tokens.map do |(col, line), type, token, _|
        LexicalToken.new([col, line], type, token)
      end
      @taggable_stack = TaggableStack.new(Taggable.new)
      @return_taggables = []
    end

    def taggables
      @taggables ||= process_taggables
    end

    protected

    def process_taggables # rubocop:disable Metrics
      @lexical_tokens.reject(&:ignored?).each do |lex|
        @current_taggable ||= Taggable.new
        next unless @current_taggable.respond_to?(lex.event)

        # send the message to the current taggable
        next_taggable = @current_taggable.public_send(lex.event, lex)

        # if return value same as current taggable, then next step
        next if next_taggable == @current_taggable

        # if return value is parent the current has ended
        if next_taggable == @current_taggable.parent
          @return_taggables << next_taggable
          @current_taggable = next_taggable
          next
        end
        @current_taggable = next_taggable
        next
      end
      @return_taggables
    end

    private

    # def current_taggable
    #   @taggable_stack.last
    # end

    def debug(message)
      return unless ENV["DEBUG"]

      puts message
    end
  end
end
