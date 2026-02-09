# Initialize Practify.config as a singleton instance of AppConfiguration
# This runs after Rails has loaded, so AppConfiguration is available via autoloading
# Calling Practify.config will memoize and return the AppConfiguration instance

# Ensure Practify::Configuration is loaded (which defines the config method)
# This needs to happen early so the config method is available
# require 'practify/preferences/preferable_class_methods'
# require 'practify/preferences/preferable'
# require 'practify/configuration'

# Use to_prepare to run configuration after all autoloading is complete
# This ensures Practify::AppConfiguration is loaded before we try to use it
Rails.application.config.to_prepare do
  # Now Practify.config is available and AppConfiguration is loaded
  Practify.config do |config|
    # Configure your Practify settings here
    # config.some_setting = "some value"
  end
end
