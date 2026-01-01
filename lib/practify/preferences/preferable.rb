module Practify
  cattr_accessor :config
  def self.config(&_block)
    yield(Practify.config) if block_given?
    @config ||= Practify::AppConfiguration.new
  end

  module Preferences
    module Preferable
      extend ActiveSupport::Concern

      included do
        extend PreferableClassMethods
      end

      def preferences_store
        @preferences_store ||= Hash.new
      end

      alias_method :preferences, :preferences_store

      def defined_preferences
        self.class.defined_preferences
      end

      def default_preferences
        Hash[
          defined_preferences.map do |name|
            [ name, send(self.class.preference_default_getter_method_name(name)) ]
          end
        ]
      end

      def set_preference(name, value)
        has_preference! name
        send self.class.preference_default_setter_method_name(name), value
      end

      def get_preference(name)
        has_preference! name
        send self.class.preference_default_getter_method_name(name)
      end

      def set_preference(name, value)
        has_preference! name
        send self.class.preference_default_setter_method_name(name), value
      end

      def has_preference!(name)
        raise NoMethodError.new "#{name} preference not defined" unless has_preference?(name)
      end

      def has_preference?(name)
        defined_preferences.include? name.to_sym
      end
    end
  end
end
