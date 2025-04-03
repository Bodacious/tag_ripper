module TagRipper
  class Ripper
    # Ruby's Ripper lib
    # https://ruby-doc.org/stdlib-2.5.1/libdoc/ripper/rdoc/Ripper.html
    require "ripper"

    def initialize(code_string)
      tokens = ::Ripper.lex(code_string)
      @lexical_tokens = tokens.map do |(col, line), type, token, _|
        LexicalToken.new([col, line], type, token)
      end
    end

    def taggables
      @taggables ||= process_taggables
    end

    def taggable_modules
      taggables.select(&:module?)
    end

    protected

    def process_taggables
      return_taggables = []
      @lexical_tokens.inject(TaggableEntity.new) do |current_taggable, lex|
        current_taggable = TaggableEntity.new if current_taggable.nil?

        next_taggable = current_taggable.send_event(lex.event, lex)
        return_taggables << current_taggable if current_taggable.closed?
        next_taggable
      end
      return_taggables
    end
  end
end
