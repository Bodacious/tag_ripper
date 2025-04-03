module TagRipper
  # Follows the state changes of a taggable entity (class, model, or method)
  # as it responds to various Lexical tokens.
  # The idea here is that this class will mutate on each new 'event', where
  # and event is the presence of a new lexical token.
  #
  # TaggableEntities begin in a pre-open state, and become open when their
  # lexical scope opens up. When a new lexical nesting is detected, a child
  # entity is spawned. This creates a sort of recursion that allows a taggable
  # entity to be flexible to any amount of code nesting.
  class TaggableEntity
    class IllegalStateTransitionError < StandardError
      def initialize(from:, to:)
        super("Cannot transition from #{from} to #{to}")
      end
    end

    def initialize(name: nil, parent: nil)
      @name = name
      @tags = Hash.new { |hash, key| hash[key] = Set.new }
      @parent = parent
      @type = nil
      @status = :pending
    end

    def send_event(event_name, lex)
      puts "send_event: #{event_name} - #{lex} #(#{@status})"
      if respond_to?(event_name, true)
        send(event_name, lex)
      else
        self
      end
    end

    def module?
      (type == :module) | (type == :class)
    end

    def type
      @type
    end
    def fqn
      return nil unless named?
      return name if fqn_names.size == 1

      if type == :instance_method
        fqn_names[0..-2].join("::") + "##{name}"
      else
        fqn_names.join("::")
      end
    end
    alias fully_qualified_name fqn

    def pending? = @status == :pending

    def tagged? = @status == :tagged

    def awaiting_name? = @status == :awaiting_name

    OPENED_STATUSES = %i[tagged awaiting_name named].freeze

    def open?
      OPENED_STATUSES.include?(@status)
    end

    def tag!(tag_name, tag_value)
      unless may_tag?
        raise IllegalStateTransitionError.new(from: @status, to: :tagged)
      end

      @status = :tagged

      add_tag(tag_name, tag_value)
    end

    def await_name!
      unless may_await_name?
        raise IllegalStateTransitionError.new(from: @status, to: :awaiting_name)
      end

      @status = :awaiting_name
    end

    def name=(name)
      unless may_name?
        raise IllegalStateTransitionError.new(from: @status, to: :named)
      end

      @name = name.to_s
      @status = :named
    end

    def close!
      @open = false
      @status = :closed
      freeze
    end

    def closed?
      @status == :closed
    end

    def may_tag?
      pending? | tagged?
    end

    def may_await_name?
      pending? | tagged?
    end

    def may_name?
      awaiting_name?
    end

    def may_close?
      named?
    end

    def inspect
      "<id=#{id},@name=#{@name},tags=#{@tags},parent=#{@parent}>"
    end

    def tags
      @tags.dup
    end

    def name
      @name.to_s.dup
    end

    def type=(type)
      @type = type.to_sym
    end

    protected

    alias id object_id

    def fqn_names
      return [name] if parent.nil?

      [*parent.fqn_names, name]
    end

    def parent
      @parent
    end

    def add_tag(name, value)
      @tags[name].add(value)
    end

    def named?
      !!@name
    end

    def build_child
      self.class.new(parent: self)
    end

    # Lex is a comment
    def on_comment(lex)
      return self unless lex.tag_comment?

      receiver = named? ? build_child : self
      if TagRipper.config.only_tags.empty? ||
         TagRipper.config.only_tags.include?(lex.tag_name)
        receiver.tag!(lex.tag_name, lex.tag_value)
      end
      receiver
    end

    # Lex is a keyword (e.g. class, module, private, end, etc.)
    def on_kw(lex)
      event_token_method_name = :"#{lex.event}_#{lex.token}"
      return self unless respond_to?(event_token_method_name, true)

      send(event_token_method_name, lex)
    end

    def on_new_taggable_context_kw(lex)
      returnable_entity = named? ? build_child : self

      returnable_entity.await_name!
      self.type = lex.on_kw_type

      returnable_entity
    end

    alias on_kw_def on_new_taggable_context_kw
    alias on_kw_module on_new_taggable_context_kw
    alias on_kw_class on_new_taggable_context_kw

    IGNORED_IDENT_KEYWORDS = %w[require private class_eval instance_eval define_method].freeze
    private_constant :IGNORED_IDENT_KEYWORDS

    def name_from_lex(lex)
      return self if IGNORED_IDENT_KEYWORDS.include?(lex.token)
      return self if named?
      return self unless may_name?

      self.name = lex.token
      self
    end

    alias on_const name_from_lex
    alias on_ident name_from_lex

    def on_kw_end(_lex)
      close!
      parent
    end
  end
end
