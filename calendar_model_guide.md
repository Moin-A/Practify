# Development Workflow: Building a Calendar from Scratch

A practical, iterative approach to building the calendar system - showing where to start and how to progress.

## Philosophy: Start Simple, Iterate, Test

1. ✅ **Make it work** (simplest version)
2. ✅ **Make it right** (add features)
3. ✅ **Make it better** (refine and optimize)

---

## Phase 1: Proof of Concept (Helper + Block)

**Goal:** Verify that `render` works with a block and you can pass data to the view.

### Step 1.1: Create the simplest helper

```ruby
# app/helpers/calendar_helper.rb
module CalendarHelper
  def simple_calendar(&block)
    raise "Block required!" unless block
    
    # Just test that the block works
    content_tag :div, class: 'calendar' do
      block.call("Test Date", ["Event 1", "Event 2"])
    end
  end
end
```

### Step 1.2: Test it in a view

```erb
<!-- app/views/meetings/index.html.erb -->
<h1>Calendar Test</h1>

<%= simple_calendar do |date, events| %>
  <p>Date: <%= date %></p>
  <p>Events: <%= events.join(", ") %></p>
<% end %>
```

**Expected Output:**
```html
<div class="calendar">
  <p>Date: Test Date</p>
  <p>Events: Event 1, Event 2</p>
</div>
```

### ✅ Checkpoint 1
- [ ] Helper accepts a block
- [ ] Block receives parameters
- [ ] Content renders in the view

**What you learned:** Helper → Block → View pipeline works!

---

## Phase 2: Add View Component Pattern

**Goal:** Move logic to a component class, verify `render_in` protocol works.

### Step 2.1: Create minimal component

```ruby
# app/components/calendar/base.rb
module Calendar
  class Base
    attr_reader :view_context
    
    def initialize(view_context)
      @view_context = view_context
    end
    
    def render_in(view_context, &block)
      @block = block
      
      # Hard-code test data
      view_context.content_tag :div, class: 'calendar' do
        @block.call("Feb 20, 2024", ["Meeting 1"])
      end
    end
  end
end
```

### Step 2.2: Update helper to use component

```ruby
# app/helpers/calendar_helper.rb
module CalendarHelper
  def simple_calendar(&block)
    raise "Block required!" unless block
    render Calendar::Base.new(self), &block
  end
end
```

### Step 2.3: Test (view stays the same)

```erb
<%= simple_calendar do |date, events| %>
  <p>Date: <%= date %></p>
  <p>Events: <%= events.join(", ") %></p>
<% end %>
```

### ✅ Checkpoint 2
- [ ] Component class created
- [ ] `render_in` method works
- [ ] Rails calls `render_in` automatically
- [ ] Block passed through correctly

**What you learned:** Rails' rendering protocol works! Component receives the block.

---

## Phase 3: Add Real Date Logic

**Goal:** Generate actual calendar dates.

### Step 3.1: Add date range method

```ruby
# app/components/calendar/base.rb
module Calendar
  class Base
    def render_in(view_context, &block)
      @block = block
      
      view_context.content_tag :div, class: 'calendar' do
        dates = date_range  # ← Use real dates now
        
        dates.map do |date|
          view_context.content_tag(:div, class: 'day') do
            @block.call(date, [])  # Empty events for now
          end
        end.join.html_safe
      end
    end
    
    def date_range
      # Simple: just this week
      today = Date.current
      (today.beginning_of_week..today.end_of_week).to_a
    end
  end
end
```

### Step 3.2: Test with real dates

```erb
<%= simple_calendar do |date, events| %>
  <strong><%= date.strftime("%A, %b %d") %></strong>
<% end %>
```

**Expected Output:**
```
Monday, Jan 15
Tuesday, Jan 16
Wednesday, Jan 17
...
```

### ✅ Checkpoint 3
- [ ] Real dates generated
- [ ] Date range logic works
- [ ] Week displayed correctly

**What you learned:** Date logic is separate from rendering!

---

## Phase 4: Extract to Partial Template

**Goal:** Move HTML structure from component to a view partial.

### Step 4.1: Create partial

```erb
<!-- app/views/shared/_calendar.html.erb -->
<div class="calendar">
  <% calendar.date_range.each do |date| %>
    <div class="day">
      <% passed_block.call(date, calendar.events_for(date)) %>
    </div>
  <% end %>
</div>
```

### Step 4.2: Update component to render partial

```ruby
# app/components/calendar/base.rb
module Calendar
  class Base
    def render_in(view_context, &block)
      @block = block
      view_context.render(
        partial: 'shared/calendar',
        locals: {
          calendar: self,
          passed_block: @block
        }
      )
    end
    
    def date_range
      today = Date.current
      (today.beginning_of_week..today.end_of_week).to_a
    end
    
    def events_for(date)
      []  # Empty for now
    end
  end
end
```

### ✅ Checkpoint 4
- [ ] Partial renders correctly
- [ ] Locals passed to partial
- [ ] Block accessible in partial
- [ ] Logic stays in component, HTML in view

**What you learned:** Separation of concerns - component has logic, partial has HTML.

---

## Phase 5: Add Event Handling

**Goal:** Pass real events and display them on correct dates.

### Step 5.1: Add events to component

```ruby
# app/components/calendar/base.rb
module Calendar
  class Base
    attr_reader :view_context, :options
    
    def initialize(view_context, options = {})
      @view_context = view_context
      @options = options
    end
    
    def events_for(date)
      return [] unless options[:events]
      
      # Simple filter: events with start_time on this date
      Array(options[:events]).select do |event|
        event.start_time.to_date == date
      end
    end
  end
end
```

### Step 5.2: Update helper to accept options

```ruby
# app/helpers/calendar_helper.rb
module CalendarHelper
  def simple_calendar(options = {}, &block)
    raise "Block required!" unless block
    render Calendar::Base.new(self, options), &block
  end
end
```

### Step 5.3: Test with real events

```ruby
# Controller
def index
  @meetings = Meeting.all
end
```

```erb
<!-- View -->
<%= simple_calendar(events: @meetings) do |date, events| %>
  <strong><%= date.day %></strong>
  <% events.each do |event| %>
    <div><%= event.name %></div>
  <% end %>
<% end %>
```

### ✅ Checkpoint 5
- [ ] Events passed through options
- [ ] Events filtered by date
- [ ] Multiple events per day work
- [ ] Real data displays

**What you learned:** Options hash pattern for configuration!

---

## Phase 6: Add Month Calendar

**Goal:** Create a full month view with inheritance.

### Step 6.1: Create Month subclass

```ruby
# app/components/calendar/month.rb
module Calendar
  class Month < Base
    def date_range
      start = start_date.beginning_of_month.beginning_of_week
      ending = start_date.end_of_month.end_of_week
      (start..ending).to_a
    end
    
    def start_date
      Date.current  # Hard-coded for now
    end
  end
end
```

### Step 6.2: Add helper method

```ruby
# app/helpers/calendar_helper.rb
module CalendarHelper
  def month_calendar(options = {}, &block)
    raise "Block required!" unless block
    render Calendar::Month.new(self, options), &block
  end
end
```

### Step 6.3: Test

```erb
<%= month_calendar(events: @meetings) do |date, events| %>
  <%= date.day %>
  <% events.each do |event| %>
    <div><%= event.name %></div>
  <% end %>
<% end %>
```

### ✅ Checkpoint 6
- [ ] Inheritance works (Month < Base)
- [ ] Full month displays
- [ ] Subclass overrides date_range

**What you learned:** Inheritance for specialized calendars!

---

## Phase 7: Add Navigation

**Goal:** Previous/Next month links.

### Step 7.1: Add URL helper methods

```ruby
# app/components/calendar/base.rb
def start_date
  if view_context.params[:start_date]
    view_context.params[:start_date].to_date
  else
    Date.current
  end
end

def url_for_next_month
  next_month = (date_range.last + 1.day).iso8601
  view_context.url_for(start_date: next_month)
end

def url_for_previous_month
  prev_month = (date_range.first - 1.day).iso8601
  view_context.url_for(start_date: prev_month)
end
```

### Step 7.2: Update partial

```erb
<!-- app/views/shared/_calendar.html.erb -->
<div class="calendar">
  <div class="calendar-nav">
    <%= link_to "← Previous", calendar.url_for_previous_month %>
    <%= link_to "Next →", calendar.url_for_next_month %>
  </div>
  
  <!-- rest of calendar -->
</div>
```

### ✅ Checkpoint 7
- [ ] Navigation links work
- [ ] URL params control displayed month
- [ ] Back/forward navigation works

**What you learned:** State management via URL params!

---

## Phase 8: Add Styling & Polish

**Goal:** Make it look good.

### Step 8.1: Add CSS classes

```ruby
# app/components/calendar/base.rb
def css_classes_for(date)
  classes = ['day']
  classes << 'today' if date == Date.current
  classes << 'weekend' if date.saturday? || date.sunday?
  classes << 'has-events' if events_for(date).any?
  classes
end
```

### Step 8.2: Update partial to use classes

```erb
<% calendar.date_range.each do |date| %>
  <div class="<%= calendar.css_classes_for(date).join(' ') %>">
    <% passed_block.call(date, calendar.events_for(date)) %>
  </div>
<% end %>
```

### Step 8.3: Add CSS

```css
.calendar .day.today { background: yellow; }
.calendar .day.weekend { color: gray; }
.calendar .day.has-events { font-weight: bold; }
```

### ✅ Checkpoint 8
- [ ] Visual styling applied
- [ ] Special days highlighted
- [ ] User experience improved

---

## Testing Strategy (Throughout)

### Manual Testing (Each Phase)
```ruby
# In rails console
helper.month_calendar(events: Meeting.all) { |d, e| "#{d}: #{e.count}" }
```

### Write Tests as You Go

**After Phase 2 (Component):**
```ruby
# test/components/calendar_test.rb
test "renders calendar" do
  calendar = Calendar::Base.new(view)
  assert_not_nil calendar
end
```

**After Phase 5 (Events):**
```ruby
test "filters events by date" do
  event = meetings(:one)
  calendar = Calendar::Base.new(view, events: [event])
  assert_includes calendar.events_for(event.start_time.to_date), event
end
```

**After Phase 7 (Navigation):**
```ruby
test "generates next month URL" do
  calendar = Calendar::Month.new(view)
  assert_includes calendar.url_for_next_month, "start_date"
end
```

---

## Summary: Development Order

```
1. Helper + Block ────────→ Verify rendering pipeline
2. Component Class ───────→ Add render_in protocol
3. Date Logic ────────────→ Generate real dates
4. Partial Template ──────→ Separate HTML from logic
5. Event Handling ────────→ Display real data
6. Inheritance ───────────→ Add Month subclass
7. Navigation ────────────→ Add URL-based state
8. Styling ───────────────→ Polish the UI
```

## Key Principles

1. **Start with the interface** - Helper method first (what devs will use)
2. **Verify each layer** - Test that render → component → partial works
3. **Hard-code first** - Use fake data, then make it dynamic
4. **One feature at a time** - Dates, then events, then navigation
5. **Test as you go** - Manual testing in browser + automated tests
6. **Refactor when working** - Don't refactor broken code

## Common Pitfalls to Avoid

❌ **Don't start with** the full database schema  
✅ **Do start with** a simple helper that renders something

❌ **Don't build** all features at once  
✅ **Do add** one feature, test it, then move on

❌ **Don't write** complex date logic first  
✅ **Do use** hard-coded dates, then make dynamic

❌ **Don't skip** manual testing  
✅ **Do check** each phase in the browser

---

## Your First Hour: Quick Start Checklist

```
[ ] 00:00 - Create helper with block test
[ ] 00:10 - Verify block works in view
[ ] 00:15 - Create component class
[ ] 00:25 - Add render_in method
[ ] 00:30 - Test component renders
[ ] 00:40 - Add simple date_range
[ ] 00:50 - Create partial template
[ ] 01:00 - ✅ Working calendar displaying dates!
```

Then iterate from there!

---

**Remember:** Every expert developer builds like this. Start simple, make it work, then make it better. 🚀
