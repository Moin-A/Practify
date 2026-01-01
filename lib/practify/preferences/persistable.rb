module Practify
  module Preferences
    module Persistable
      extend ActiveSupport::Concern
      included do
        include Preferable
        # Persistence logic goes here
        serialize :preferences, JSON

        after_initialize :initialize_preferences_defaults
      end

      private

      def initialize_preferences_defaults
        self.preferences.merge(default_preferences)
      end
    end
  end
end
