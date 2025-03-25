module TagRipper
  class LexicalToken
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
end