require 'rails_helper'
require 'view_component/test_helpers'

RSpec.describe Calendars::Base, type: :component do
  include ViewComponent::TestHelpers

  describe '#initialize' do
    it 'initializes with today\'s date by default' do
      context = vc_test_controller.view_context
      calendar = Calendars::Base.new(context)
      expect(calendar.instance_variable_get(:@view_context)).to eq(context)
    end


    it 'returns the partial name' do
      context = vc_test_controller.view_context
      calendar = Calendars::Base.new(context)
      expect(calendar.partial_name).to eq('calendars/base')
    end

    # it 'renders the partial' do
    #   context = vc_test_controller.view_context
    #   rendered_html = render_inline(Calendars::Base.new(vc_test_controller.view_context) { "Hello from the block!" }){ "Hello from the block!" }
    #   expect(rendered_html.to_html).to match(/<div>.*<h1>Calendar Base<\/h1>.*<\/div>/m)
    # end
  end
end
