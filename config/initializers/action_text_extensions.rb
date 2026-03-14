Rails.application.config.to_prepare do
  ActionText::Attachment.prepend(Module.new do
    def node
      super.tap do |node|
        # You can keep binding.pry for debugging if needed
        node["width"] = "200"
        node["height"] = "200"
      end
    end
  end)
end
