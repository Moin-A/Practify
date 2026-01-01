module Practify
  cattr_accessor :config


  def self.config(&_block)
    yield(Practify.config) if block_given?
    @config ||= Practify::AppConfiguration.new
  end

  class AppConfiguration < Practify::Configuration
    preference :some_setting, :string, default: "default_value"
  end
end
