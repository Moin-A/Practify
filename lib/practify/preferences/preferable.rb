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

      def convert_preference_value(value, type, preference_encryptor = nil)
        return nil if value.nil?
        case type
        when :string, :text
          value.to_s
        when :encrypted_string
          preference_encryptor.encrypt(value.to_s)
        when :password
          value.to_s
        when :decimal
          begin
            value.to_s.to_d
          rescue ArgumentError
            BigDecimal(0)
          end
        when :integer
          value.to_i
        when :boolean
          if !value ||
             value.to_s =~ /\A(f|false|0|^)\Z/i ||
             (value.respond_to?(:empty?) && value.empty?)
            false
          else
            true
          end
        when :array
          raise TypeError, "Array expected got #{value.inspect}" unless value.is_a?(Array)
          value
        when :hash
          raise TypeError, "Hash expected got #{value.inspect}" unless value.is_a?(Hash)
          value
        else
          value
        end
      end

      


      def defined_preferences
        self.class.defined_preferences
      end

      def default_preferences
        Hash[
          defined_preferences.map do |name|
            [ name, preference_default(name) ]
          end
        ]
      end

      def preference_default(name)
        has_preference! name
        send "preferred_#{name}_default"
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
