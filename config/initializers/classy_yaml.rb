# Configure Classy::Yaml to use utility_classes.yml
Classy::Yaml.setup do |config|
  config.default_file = Rails.root.join("config", "utility_classes.yml")
end
