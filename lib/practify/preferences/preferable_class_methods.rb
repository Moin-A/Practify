module Practify
  module Preferences
    module PreferableClassMethods
      def defined_preferences
        []
      end

      def preference_default_getter_method_name(name)
        "preferred_#{name}"
      end

      def preference_default_setter_method_name(name)
        "preferred_#{name}="
      end

      def preference_default_method_name(name)
        "preferred_#{name}_default"
      end

      def preference(name, type, options = {})
        options.assert_valid_keys(:default, :encryption_key)
        name = name.to_sym
        defined_singleton_preferences = (@defined_singleton_preferences ||= [])
        defined_singleton_preferences << name.to_sym

        define_singleton_method :defined_preferences do
          super() + defined_singleton_preferences
        end

        encrypter = nil
        if type == :encrypted_string
          encrypter = Practify::Encrypter.new(Rails.application.credentials.secret_key_base)
          options[:default] = encrypter.encrypt(options[:default])
        end

        default = if options[:default].is_a?(Proc)
          options[:default]
        else
          proc { options[:default].dup rescue options[:default] }
        end

        # Capture method name for closure
        default_method_name = preference_default_method_name(name)

        # Define preferred_#{name}_default method
        define_method default_method_name do
          instance_exec(&default)
        end

        # Define preferred_#{name} getter
        define_method preference_default_getter_method_name(name) do
          value = preferences.fetch(name) do
            default_value = send(default_method_name)
            preferences[name] = default_value
            default_value
          end
          value = encrypter.decrypt(value) if encrypter.present? && value.present?
          value
        end

        # Define preferred_#{name}= setter
        define_method preference_default_setter_method_name(name) do |value|
          value = convert_preference_value(value, type, encrypter)
          preferences[name] = value
        end
      end

      private

     
    end
  end
end
