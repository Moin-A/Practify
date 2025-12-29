module Practify
  class << self
    attr_accessor :config
  end

  def self.config(&_block)
    yield(Practify.config) if block_given?
    @config ||= Practify::AppConfiguration.new
  end

  class AppConfiguration
    # Add your configuration attributes here
    # Example:
    attr_accessor :some_setting, :api_key

    def initialize
      @some_setting # Set default values here if needed
      @api_key = "1234567890"
    end
  end
end
