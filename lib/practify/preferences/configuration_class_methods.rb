module Practify
  module Preferences
    module ConfigurationClassMethods
        def defined_preferences
            []
        end

        def preference(name, type, options = {})
            options.assert_valid_keys(:default, :encryption_key)
            defined_singleton_preferences = (@defined_singleton_preferences ||= [])
            defined_singleton_preferences << name.to_sym

            define_singleton_method :defined_preferences do
                super() + defined_singleton_preferences
            end

            define_method "default_#{name}_preference" do
                options[:default]
            end
        end
      end
   end
end
