class LexicalTokenStubFactory
  class ModuleStub < self
    def defaults = { type: :on_kw, token: "module" }

    def on_kw_type = "module"
  end

  class OnIdentStub < self
    def defaults = { type: :on_ident, token: "Foo" }
  end

  class ClassStub < self
    def defaults = { type: :on_kw, token: "class" }

    def on_kw_type = "module"
  end

  def initialize(**attributes)
    @attributes = attributes
    @attributes[:id] = Random.random_number
    @attributes = defaults.merge(@attributes)
    @attributes[:event] = @attributes[:type]
    build_attributes
  end

  def build_attributes
    # noop
  end

  def defaults = { col: 0, line: 0, type: :on_kw, token: "module" }

  def self.create(factory_name, **attributes)
    camelcase_name = factory_name.to_s.gsub(/(?:^|_)\w/, &:upcase).delete("_")
    camelcase_name << "Stub"
    unless const_defined?(camelcase_name)
      raise ArgumentError, "#{camelcase_name} is not a valid factory"
    end

    const_get(camelcase_name).new(**attributes)
  end

  def self.create_module
    new(
      type: :on_kw,
      token: "module"
    ).build_stub
  end

  def id
    @attributes[:id]
  end

  def build_stub
    stub("mystub", **attributes)
  end

  def attributes
    @attributes
  end

  def method_missing(method_name, *arguments, &)
    if @attributes.key?(method_name.to_sym)
      @attributes[method_name]
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    @attributes.key?(method_name.to_sym) || super
  end
end
