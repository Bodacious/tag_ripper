module Minitest
  class Test
    protected

    def described_class
      Object.const_get(self.class.name.sub(/Test$/, ""))
    end
  end
end
