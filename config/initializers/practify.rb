# Initialize Practify.config as a singleton instance of AppConfiguration
# This runs after Rails has loaded, so AppConfiguration is available via autoloading
# Calling Practify.config will memoize and return the AppConfiguration instance
# Practify.config do |config|
#   config.some_setting = "some value"
# end
