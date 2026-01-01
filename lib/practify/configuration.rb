module Practify
    class Configuration
      include Preferences::Preferable



      alias :[] :get_preference
      alias :get :get_preference
      alias :[]= :set_preference
    end
end
