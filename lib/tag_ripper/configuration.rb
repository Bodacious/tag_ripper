module TagRipper
  class Configuration
    def initialize
      @only_tags = Set.new
      @except_tags = Set.new
    end

    def eval_config(&block)
      block.call(self)
    end

    def only_tags
      @only_tags.dup
    end

    def only_tags=(tags)
      @only_tags = tags.to_set
    end

    def except_tags
      @except_tags.dup
    end

    def except_tags=(tags)
      @except_tags = tags.to_set
    end
  end
end
