module Practify
  module Preferences
    class Configuration
      include Preferable

      def preferences_store
        @preferences_store ||= Hash.new
      end

      alias :[] :get_preference
      alias :get :get_preference
      alias :[]= :set_preference
      alias_method :preferences, :preferences_store
    end
  end
end
