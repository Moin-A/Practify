require 'rails_helper'

RSpec.describe CalendarsHelper, type: :helper do
    it "renders calendar with block content" do
    result = render inline: <<~ERB
      <%= calendar do %>
        <p>Hello from the block!</p>
      <% end %>
    ERB

    expect(result).to have_selector("div p", text: "Hello from the block!")
    end
end
