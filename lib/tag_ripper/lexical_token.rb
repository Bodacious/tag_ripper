module TagRipper
  class LexicalToken
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

    def to_s
      token
    end

    alias event type

    def comment?
      type == :on_comment
    end

    def tag_comment?
      comment? && token.match?(/# @domain: (.+)/)
    end

    def tag_name
      "domain"
    end

    def tag_values
      token.scan(/# @domain: (.+)/)[0]
    end

    alias tag_value tag_values

    def end?
      keyword? && token.match(/end/)
    end
  end
end
