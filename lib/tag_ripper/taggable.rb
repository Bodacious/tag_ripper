module TagRipper
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

    def build_child
      self.class.new(parent: self)
    end
  end
end
