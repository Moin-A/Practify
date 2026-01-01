module Practify
  class AppConfiguration < Practify::Configuration
    preference :some_setting, :string, default: "default_value"
  end
end
