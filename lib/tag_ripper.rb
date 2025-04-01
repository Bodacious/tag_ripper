# frozen_string_literal: true

require "set" unless defined?(Set)

require_relative "tag_ripper/ripper"
require_relative "tag_ripper/lexical_token"
require_relative "tag_ripper/taggable_entity"
require_relative "tag_ripper/configuration"
module TagRipper
  class << self
    def configure(&)
      configuration.eval_config(&)
    end

    def configuration
      @configuration ||= reset_configuration!
    end
    alias config configuration

    def reset_configuration!
      @configuration = Configuration.new
    end
  end
end
