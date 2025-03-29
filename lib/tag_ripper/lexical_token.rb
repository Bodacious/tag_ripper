module TagRipper
  class LexicalToken
    TAG_REGEX = /#\s@(?<tag_name>[\w_-]+):\s(?<tag_value>.+)/

    class Location
      attr_reader :col
      attr_reader :line

      def initialize(col, line)
        @col = col
        @line = line
        freeze
      end
    end
    private_constant :Location

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

    def to_s
      token
    end

    alias event type

    def comment?
      type == :on_comment
    end

    def tag_comment?
      # binding.irb
      comment? && token.match?(TAG_REGEX)
    end

    def tag_name
      return nil unless tag_comment?

      token.match(TAG_REGEX)[:tag_name]
    end

    def tag_values
      return nil unless tag_comment?

      token.match(TAG_REGEX)[:tag_value]
    end

    alias tag_value tag_values

    def end?
      keyword? && token.match(/end/)
    end
  end
end
