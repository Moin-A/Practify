module Practify
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
