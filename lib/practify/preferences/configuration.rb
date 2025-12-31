module Practify
  module Preferences
    class Configuration
      # Configuration logic goes here
      class << self
        def defined_preferences
          []
        end

        def preference(name, type, options = {})
          options.assert_valid_keys(:default, :encryption_key)
          defined_singleton_preferences = (@defined_signeton_preferences ||= [])
          defined_singleton_preferences << name.to_sym

          define_singleton_method :defined_preferences do
            super() + defined_singleton_preferences
          end
        end
      end
    end
  end
end
