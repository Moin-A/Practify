# Building Your Own Simple Calendar

A step-by-step guide to implement a trimmed-down calendar component in your Rails app without installing the gem.

## Why Build Your Own?

- 🎓 Learn how Rails view components work
- 🎯 Full control over features and customization
- 📦 No external dependencies
- 🔧 Add features incrementally as needed

## Overview

We'll build a minimal month calendar that:
- Renders a calendar grid for any month
- Displays events on specific dates
- Handles navigation (Previous/Next/Today)
- Allows custom rendering of each day

## File Structure

```
app/
├── components/
│   └── calendar/
│       ├── base.rb                    # Calendar::Base
│       ├── month.rb                   # Calendar::Month
│       ├── week.rb                    # Calendar::Week (optional)
│       └── business_week.rb           # Calendar::BusinessWeek (optional)
├── helpers/
│   └── calendar_helper.rb             # Helper methods
├── views/
│   └── shared/
│       └── _calendar.html.erb         # Calendar partial
└── assets/
    └── stylesheets/
        └── calendar.css               # Calendar styles
```

**Why `app/components/`?**
- ✅ Rails autoloads everything automatically
- ✅ No manual `require` statements needed
- ✅ Modern Rails convention for view components
- ✅ Clean and organized

## Step 1: Create the Calendar Component Classes

### Base Calendar Class

Create `app/components/calendar/base.rb`:

```ruby
module Calendar
  class Base
  attr_reader :view_context, :options

  def initialize(view_context, options = {})
    @view_context = view_context
    @options = options
  end

  # Rails calls this method when rendering the component
  def render_in(view_context, &block)
    @block = block
    view_context.render(
      partial: 'shared/calendar',
      locals: {
        calendar: self,
        date_range: date_range,
        start_date: start_date,
        passed_block: @block
      }
    )
  end

  # Generate date range (can be overridden by subclasses)
  def date_range
    # Default implementation - override in subclasses
    (start_date..(start_date + 6.days)).to_a
  end

  # Get the start date from params or use current date
  def start_date
    if options.key?(:start_date)
      options[:start_date].to_date
    else
      param_date = view_context.params[:start_date]
      param_date ? param_date.to_date : Date.current
    end
  end

  # Group events by date for easy lookup
  def sorted_events
    @sorted_events ||= begin
      events = Array(options[:events])
      group_events_by_date(events)
    end
  end

  # Get events for a specific day
  def sorted_events_for(day)
    sorted_events[day] || []
  end

  # CSS classes for each day cell
  def td_classes_for(day)
    today = Date.current
    classes = ['day']
    classes << "wday-#{day.wday}"
    classes << 'today' if today == day
    classes << 'past' if today > day
    classes << 'future' if today < day
    classes << 'current-month' if start_date.month == day.month
    classes << 'prev-month' if start_date.month != day.month && day < start_date
    classes << 'next-month' if start_date.month != day.month && day > start_date
    classes << 'has-events' if sorted_events_for(day).any?
    classes
  end

  # Navigation URLs
  def url_for_next_view
    params = view_context.params.to_unsafe_h.except(:authenticity_token, :commit)
    next_month = (date_range.last + 1.day).iso8601
    view_context.url_for(params.merge(start_date: next_month))
  end

  def url_for_previous_view
    params = view_context.params.to_unsafe_h.except(:authenticity_token, :commit)
    prev_month = (date_range.first - 1.day).iso8601
    view_context.url_for(params.merge(start_date: prev_month))
  end

  def url_for_today_view
    params = view_context.params.to_unsafe_h.except(:authenticity_token, :commit)
    view_context.url_for(params.merge(start_date: Date.current.iso8601))
  end

  private

  def group_events_by_date(events)
    events_by_date = Hash.new { |h, k| h[k] = [] }
    
    events.each do |event|
      next unless event.respond_to?(:start_time)
      
      start_date = event.start_time.to_date
      end_date = event.respond_to?(:end_time) && event.end_time ? 
                 event.end_time.to_date : start_date
      
      (start_date..end_date).each do |date|
        events_by_date[date] << event
      end
    end
    
    events_by_date
  end
  end
end
```

### Month Calendar Class

Create `app/components/calendar/month.rb`:

```ruby
module Calendar
  class Month < Base
    def date_range
      beginning = start_date.beginning_of_month.beginning_of_week
      ending = start_date.end_of_month.end_of_week
      (beginning..ending).to_a
    end

    def url_for_previous_view
      params = view_context.params.to_unsafe_h.except(:authenticity_token, :commit)
      prev_month = (date_range.first - 1.day).iso8601
      view_context.url_for(params.merge(start_date: prev_month))
    end
  end
end
```

**That's it for the classes!** Rails will automatically load them from `app/components/`.

## Step 2: Create the Helper Module

Create `app/helpers/calendar_helper.rb`:

```ruby
module CalendarHelper
  def month_calendar(options = {}, &block)
    raise "month_calendar requires a block" unless block
    render Calendar::Month.new(self, options), &block
  end

  def week_calendar(options = {}, &block)
    raise "week_calendar requires a block" unless block
    render Calendar::Week.new(self, options), &block
  end
end
```

## Step 3: Create the Partial View

Create `app/views/shared/_calendar.html.erb`:

```erb
<div class="simple-calendar">
  <div class="calendar-heading">
    <span class="calendar-title">
      <%= Date::MONTHNAMES[start_date.month] %> <%= start_date.year %>
    </span>

    <nav class="calendar-nav">
      <%= link_to "← Previous", calendar.url_for_previous_view, class: "nav-link" %>
      <%= link_to "Today", calendar.url_for_today_view, class: "nav-link" %>
      <%= link_to "Next →", calendar.url_for_next_view, class: "nav-link" %>
    </nav>
  </div>

  <table class="calendar-table">
    <thead>
      <tr>
        <% date_range.slice(0, 7).each do |day| %>
          <th><%= Date::ABBR_DAYNAMES[day.wday] %></th>
        <% end %>
      </tr>
    </thead>

    <tbody>
      <% date_range.each_slice(7) do |week| %>
        <tr class="calendar-week">
          <% week.each do |day| %>
            <td class="<%= calendar.td_classes_for(day).join(' ') %>">
              <div class="day-content">
                <% 
                  # Execute the user's block for this day
                  instance_exec(day, calendar.sorted_events_for(day), &passed_block) 
                %>
              </div>
            </td>
          <% end %>
        </tr>
      <% end %>
    </tbody>
  </table>
</div>
```

## Step 4: Add Basic Styles

Create `app/assets/stylesheets/calendar.css`:

```css
.simple-calendar {
  border: 1px solid #ddd;
  border-radius: 4px;
  margin: 20px 0;
}

.calendar-heading {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 20px;
  background: #f8f9fa;
  border-bottom: 1px solid #ddd;
}

.calendar-title {
  font-size: 1.25rem;
  font-weight: 600;
}

.calendar-nav {
  display: flex;
  gap: 10px;
}

.calendar-nav .nav-link {
  padding: 5px 15px;
  text-decoration: none;
  background: white;
  border: 1px solid #ddd;
  border-radius: 3px;
  color: #333;
}

.calendar-nav .nav-link:hover {
  background: #e9ecef;
}

.calendar-table {
  width: 100%;
  border-collapse: collapse;
}

.calendar-table th {
  padding: 10px;
  text-align: center;
  background: #f8f9fa;
  border-bottom: 1px solid #ddd;
  font-weight: 600;
}

.calendar-table td {
  padding: 10px;
  vertical-align: top;
  border: 1px solid #eee;
  min-height: 80px;
  height: 100px;
}

.calendar-table td.today {
  background: #fff3cd;
}

.calendar-table td.past {
  color: #999;
}

.calendar-table td.prev-month,
.calendar-table td.next-month {
  background: #f8f9fa;
  color: #aaa;
}

.calendar-table td.has-events {
  background: #e7f3ff;
}

.day-content {
  font-size: 0.9rem;
}
```

Import in `app/assets/stylesheets/application.css`:
```css
*= require calendar
```

## Step 5: Usage in Your App

### Create a Model with Events

```ruby
# app/models/meeting.rb
class Meeting < ApplicationRecord
  # Has columns: name, start_time, end_time
end
```

### Controller

```ruby
# app/controllers/meetings_controller.rb
class MeetingsController < ApplicationController
  def index
    start_date = params.fetch(:start_date, Date.today).to_date
    
    # Fetch events for the visible date range
    @meetings = Meeting.where(
      start_time: start_date.beginning_of_month.beginning_of_week..
                  start_date.end_of_month.end_of_week
    )
  end
end
```

### View

```erb
<!-- app/views/meetings/index.html.erb -->
<h1>My Calendar</h1>

<%= month_calendar(events: @meetings) do |date, meetings| %>
  <div class="date-number"><%= date.day %></div>
  
  <% meetings.each do |meeting| %>
    <div class="event">
      <%= link_to meeting.name, meeting %>
    </div>
  <% end %>
<% end %>
```

## Step 6: Test It

### Generate a Migration

```bash
rails g model Meeting name:string start_time:datetime end_time:datetime
rails db:migrate
```

### Seed Some Data

```ruby
# db/seeds.rb
Meeting.create(name: "Team Standup", start_time: Date.today.at_noon)
Meeting.create(name: "Client Meeting", start_time: 2.days.from_now.at_noon)
Meeting.create(name: "Code Review", start_time: Date.today + 1.week)
```

```bash
rails db:seed
```

### Visit Your Calendar

Navigate to `/meetings` and you should see your calendar with events!

## Extending Your Calendar

### Add Week View

Create `app/components/calendar/week.rb`:

```ruby
module Calendar
  class Week < Base
    def date_range
      beginning = start_date.beginning_of_week
      ending = start_date.end_of_week
      (beginning..ending).to_a
    end

    def url_for_previous_view
      params = view_context.params.to_unsafe_h.except(:authenticity_token, :commit)
      prev_week = (date_range.first - 1.day).iso8601
      view_context.url_for(params.merge(start_date: prev_week))
    end
  end
end
```

Rails will automatically load it!

### Add Custom Business Week Calendar

Create `app/components/calendar/business_week.rb`:

```ruby
module Calendar
  class BusinessWeek < Base
    def date_range
      beginning = start_date.monday
      ending = beginning + 4.days  # Monday to Friday
      (beginning..ending).to_a
    end

    def url_for_previous_view
      params = view_context.params.to_unsafe_h.except(:authenticity_token, :commit)
      prev_week = (date_range.first - 7.days).iso8601
      view_context.url_for(params.merge(start_date: prev_week))
    end
  end
end
```

Add to helper:
```ruby
def business_week_calendar(options = {}, &block)
  raise "business_week_calendar requires a block" unless block
  render Calendar::BusinessWeek.new(self, options), &block
end
```

### Add Event Filtering by Attribute

```ruby
def initialize(view_context, options = {})
  @view_context = view_context
  @options = options
  @attribute = options.fetch(:attribute, :start_time)
  @end_attribute = options.fetch(:end_attribute, :end_time)
end

def group_events_by_date(events)
  events_by_date = Hash.new { |h, k| h[k] = [] }
  
  events.each do |event|
    next unless event.respond_to?(@attribute)
    
    start_date = event.send(@attribute).to_date
    end_date = event.respond_to?(@end_attribute) && event.send(@end_attribute) ? 
               event.send(@end_attribute).to_date : start_date
    
    (start_date..end_date).each do |date|
      events_by_date[date] << event
    end
  end
  
  events_by_date
end
```

### Add Time Zone Support

```ruby
def start_date
  date = if options.key?(:start_date)
    options[:start_date]
  else
    view_context.params[:start_date] || Date.current
  end
  
  date.to_date.in_time_zone(Time.zone)
end
```

## Tips & Best Practices

1. **Start Simple**: Get basic month view working first
2. **Add Features Gradually**: Only add what you actually need
3. **Test Edge Cases**: Month boundaries, time zones, nil events
4. **Performance**: Index your datetime columns for date range queries
5. **Caching**: Consider fragment caching for large calendars

## Common Customizations

### Custom Date Format
```erb
<%= month_calendar do |date, meetings| %>
  <div><%= date.strftime("%d %b") %></div>
<% end %>
```

### Event Colors by Type
```erb
<% meetings.each do |meeting| %>
  <div class="event <%= meeting.priority %>">
    <%= meeting.name %>
  </div>
<% end %>
```

### Click to Create Event
```erb
<%= month_calendar do |date, meetings| %>
  <%= link_to date.day, new_meeting_path(start_date: date), class: "date-link" %>
  <!-- events here -->
<% end %>
```

## Troubleshooting

### "undefined method `params`"
Make sure `view_context` is passed correctly in `initialize`

### Events not showing
Check that your model has `start_time` attribute or pass custom `attribute: :your_date_field`

### Navigation broken
Ensure your routes support the `start_date` param

### Dates in wrong timezone
Set `config.time_zone` in `config/application.rb`

## Next Steps

Once you have the basics working:
1. Add AJAX navigation with Turbo/Hotwire
2. Implement drag-and-drop event creation
3. Add filtering and searching
4. Create mobile-responsive design
5. Add export to iCal functionality

## Migrating to the Gem Later

If you decide to use the official gem later:
1. Add `gem 'simple_calendar'` to Gemfile
2. Replace `Calendar::Month` with `SimpleCalendar::MonthCalendar`
3. Update partial paths
4. Remove your custom `app/components/calendar/` directory

Your view code will mostly stay the same!

## Quick Reference

### Classes
```ruby
Calendar::Base           # Base class with shared logic
Calendar::Month          # Month view (full month grid)
Calendar::Week           # Week view (7 days)
Calendar::BusinessWeek   # Business week (Mon-Fri)
```

### Helper Methods
```ruby
month_calendar(options = {}, &block)
week_calendar(options = {}, &block)
business_week_calendar(options = {}, &block)
```

### Options Hash
```ruby
{
  events: @meetings,              # Collection of events
  start_date: Date.today,         # Starting date
  attribute: :start_time,         # Date attribute name
  end_attribute: :end_time        # End date attribute (optional)
}
```

### Block Parameters
```ruby
month_calendar do |date, events|
  # date: Date object for the current day
  # events: Array of events for that day
end
```

## Benefits of Namespacing

✅ **Organization**: Related classes grouped together  
✅ **Scalability**: Easy to add new calendar types  
✅ **Clean**: `Calendar::Month` vs `MonthCalendarComponent`  
✅ **Professional**: Follows Rails conventions  
✅ **No conflicts**: Won't clash with other calendar code  

---

**Happy coding! 📅**
