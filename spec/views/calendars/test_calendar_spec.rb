require 'rails_helper'

RSpec.describe 'calendars views', type: :view do
  describe 'test_base_component' do
    before do
      assign(:date, Date.new(2024, 6, 15))
      render template: 'calendars/test_base_component'
    end
  end

  describe 'test_calendar (with month_calendar helper)' do
    let(:meetings) { [] }

    before do
      assign(:meetings, meetings)
    end

    context 'when SimpleCalendar is available' do
      before do
        if defined?(SimpleCalendar)
          render template: 'calendars/test_calendar'
        end
      end

      it 'renders the calendar with month_calendar helper' do
        skip 'SimpleCalendar gem not installed' unless defined?(SimpleCalendar)
        expect(rendered).to be_present
      end
    end
  end
end
