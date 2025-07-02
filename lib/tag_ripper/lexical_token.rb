module TagRipper
  class LexicalToken
    require "forwardable"
    extend Forwardable

    TAG_REGEX = /#\s@(?<tag_name>[\w-]+):\s(?<tag_value>.+)/

    ##
    # = Operators =

    DOUBLE_COLON = "::".freeze
    SINGLETON_CLASS = "<<".freeze

    ##
    # = Keywords =

    KEYWORD_CONST = "const".freeze
    KEYWORD_DEF = "def".freeze
    KEYWORD_END = "end".freeze
    KEYWORD_MODULE = "module".freeze

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

    def_delegators :location, :col, :line

    attr_reader :location

    attr_reader :type

    def initialize((col, line), type, token)
      @location = Location.new(col, line)
      @type = type.to_sym
      @token = token.to_s
    end

    def to_s
      token
    end

    alias event type

    def token
      @token.dup
    end

    def comment?
      type == :on_comment
    end

    def tag_comment?
      comment? && token.match?(TAG_REGEX)
    end

    def double_colon?
      token == DOUBLE_COLON
    end

    def singleton_class?
      token == SINGLETON_CLASS
    end

    def keyword?
      type == :on_kw
    end

    def end?
      keyword? && token == KEYWORD_END
    end

    def tag_name
      return nil unless tag_comment?

      token.match(TAG_REGEX)[:tag_name]
    end

    def tag_value
      return nil unless tag_comment?

      token.match(TAG_REGEX)[:tag_value]
    end

    def on_kw_type
      return nil unless keyword?

      case token
      when KEYWORD_CONST then :class
      when KEYWORD_MODULE then :module
      when KEYWORD_DEF then :instance_method
      else
        :unknown
      end
    end
  end
end
