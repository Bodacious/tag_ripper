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

    alias id object_id

    def inspect
      "<id=#{object_id},@name=#{@name},tags=#{@tags},parent=#{@parent}>"
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

    def closed?
      @ended
    end

    def open
      @open = true
    end

    def close
      @open = false
      @ended = true
    end

    def state
      return "ended" if closed?
      return "blank" if blank?
      return "named" if named?
      return "awaiting_name" if open? && !named?
      return "tagged" if tags.any?

      "open"
    end

    def build_child
      self.class.new(parent: self)
    end

    def on_comment(lex)
      add_tag(lex.tag_name, lex.tag_value)
      self
    end

    def on_kw(lex)
      event_token_method_name = :"#{lex.event}_#{lex.token}"
      return self unless respond_to?(event_token_method_name)

      send(event_token_method_name, lex)
    end

    def on_new_taggable_context_kw(_lex)
      return self if named?

      open

      self
    end

    alias on_kw_def on_new_taggable_context_kw
    alias on_kw_module on_new_taggable_context_kw
    alias on_kw_class on_new_taggable_context_kw

    def on_kw_end(_lex)
      close
      parent
    end

    def name_from_lex(lex)
      @name = lex.token
      @type = lex.type
      build_child
    end

    alias on_const name_from_lex
    alias on_ident name_from_lex
  end
end
