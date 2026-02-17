module Practify
  class << self
    def config
      @config ||= AppConfiguration.new
      yield @config if block_given?
      @config
    end

    def bus
      @bus ||= Omnes::Bus.new
      yield @bus if block_given?
      @bus
    end
  end
end
