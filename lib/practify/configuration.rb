module Practify
  class Configuration
    include Preferences::Preferable
    extend Preferences::ConfigurationClassMethods

    alias_method :preferences, :preferences_store

    alias :[] :get_preference
    alias :get :get_preference
    alias :[]= :set_preference
  end
end
