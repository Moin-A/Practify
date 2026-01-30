# How Single-Page Rendering Works in Practify

This document explains how Practify achieves a Single-Page Application (SPA) experience using Rails and Hotwire (Turbo).

## Architecture Overview

Practify uses **Hotwire (Turbo)** to create a single-page application experience without writing JavaScript for navigation. The sidebar stays persistent while content changes smoothly without page reloads.

## Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    1. APPLICATION LAYOUT                     │
│  (app/views/layouts/application.html.erb)                   │
│                                                              │
│  ┌──────────────┐  ┌────────────────────────────────────┐  │
│  │              │  │                                    │  │
│  │  NavComponent│  │      <main class="flex-1">        │  │
│  │  (Sidebar)   │  │         <%= yield %>              │  │
│  │              │  │      </main>                       │  │
│  │  - Fixed     │  │                                    │  │
│  │  - Persistent│  │  Content changes here via Turbo   │  │
│  │  - Never     │  │  without reloading sidebar        │  │
│  │    reloads   │  │                                    │  │
│  │              │  │                                    │  │
│  └──────────────┘  └────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## Step-by-Step Flow

### 1. Initial Page Load (First Visit)

```
User visits: https://yourapp.com/
                    ↓
┌───────────────────────────────────────────────────────────┐
│ Browser makes FULL HTTP request                           │
│ GET / HTTP/1.1                                            │
│ Accept: text/html                                         │
└───────────────────────────────────────────────────────────┘
                    ↓
┌───────────────────────────────────────────────────────────┐
│ Rails Server                                              │
│ • HomeController#show                                     │
│ • Renders application.html.erb (full layout)             │
│ • Checks if authenticated? → YES                          │
│ • Renders NavComponent (sidebar)                          │
│ • Renders home/show.html.erb in <main>                   │
└───────────────────────────────────────────────────────────┘
                    ↓
┌───────────────────────────────────────────────────────────┐
│ Complete HTML sent to browser                             │
│ <!DOCTYPE html>                                           │
│ <html>                                                    │
│   <head>                                                  │
│     <script src="turbo.min.js"></script>                  │
│   </head>                                                 │
│   <body>                                                  │
│     <div class="flex">                                    │
│       <aside>NavComponent</aside>                         │
│       <main>HomePage content</main>                       │
│     </div>                                                │
│   </body>                                                 │
│ </html>                                                   │
└───────────────────────────────────────────────────────────┘
                    ↓
        ✅ Turbo.js is now active in browser
```

---

### 2. Navigation Click (SPA Behavior Starts Here)

User clicks "Calendar" link in sidebar:

```erb
<%= link_to calendar_path, 
    data: { turbo_stream: true } do %>
  Calendar
<% end %>
```

**What happens:**

```
User clicks Calendar link
         ↓
┌────────────────────────────────────────────────────────┐
│ Turbo.js intercepts the click                          │
│ • Prevents default browser navigation                  │
│ • Reads data-turbo-stream="true"                       │
│ • Makes AJAX request instead of full page reload       │
└────────────────────────────────────────────────────────┘
         ↓
┌────────────────────────────────────────────────────────┐
│ AJAX Request (made by Turbo)                           │
│ GET /calendars/1 HTTP/1.1                              │
│ Accept: text/vnd.turbo-stream.html  ← Special header! │
│ X-Requested-With: XMLHttpRequest                       │
└────────────────────────────────────────────────────────┘
         ↓
┌────────────────────────────────────────────────────────┐
│ Rails Server (CalendarsController#show)                │
│ • Sees Accept header: text/vnd.turbo-stream.html       │
│ • Responds with Turbo Stream format                    │
│ • NO LAYOUT rendered (application.html.erb skipped)    │
│ • Only renders the content fragment                    │
└────────────────────────────────────────────────────────┘
         ↓
┌────────────────────────────────────────────────────────┐
│ Response: Turbo Stream HTML                            │
│ <turbo-stream action="replace" target="dashboard">     │
│   <template>                                           │
│     <div id="dashboard">                               │
│       <h1>Calendar</h1>                                │
│       <!-- Calendar content here -->                   │
│     </div>                                             │
│   </template>                                          │
│ </turbo-stream>                                        │
└────────────────────────────────────────────────────────┘
         ↓
┌────────────────────────────────────────────────────────┐
│ Turbo.js processes response                            │
│ • Finds element with id="dashboard"                    │
│ • Replaces ONLY that element's content                 │
│ • NavComponent (sidebar) stays untouched               │
│ • No page reload, no flash, smooth transition          │
└────────────────────────────────────────────────────────┘
         ↓
        ✅ Calendar content appears, sidebar stays!
```

---

## Key Technologies Working Together

### 1. Turbo Drive (Automatic Navigation)

```javascript
// Imported in app/javascript/application.js
import "@hotwired/turbo-rails"
```

**What it does:**
- Intercepts ALL link clicks automatically
- Converts them to AJAX requests
- Swaps page content without full reload
- Updates browser history (back/forward buttons work!)
- Shows progress bar during navigation

### 2. Turbo Streams (Partial Updates)

```erb
<!-- In nav_component.html.erb -->
<%= link_to calendar_path, 
    data: { turbo_stream: true } do %>
```

**The `data: { turbo_stream: true }` attribute tells Turbo:**
- Request Turbo Stream format specifically
- Server should return stream response
- Update ONLY specific parts of page

### 3. Persistent Layout

```erb
<!-- application.html.erb -->
<div class="flex">
  <%= render NavComponent.new(current_user: current_user) %>
  <main class="flex-1">
    <%= yield %>  ← Only this changes
  </main>
</div>
```

**Why it works:**
- **Initial load**: Full HTML (layout + content)
- **Subsequent navigation**: Only `<main>` content changes
- **Sidebar**: Never re-rendered, stays in DOM

---

## Comparison: Traditional vs Turbo

### Traditional Rails (Full Page Reload)

```
User clicks link
     ↓
Browser navigates to new URL
     ↓
Server renders ENTIRE page (layout + content)
     ↓
Browser throws away current page
     ↓
Browser parses new HTML
     ↓
Browser loads CSS, JS again
     ↓
Sidebar re-renders (flash/blink)
     ↓
Content appears
     ↓
Total time: ~500-1000ms
```

### Practify with Turbo (SPA-like)

```
User clicks link
     ↓
Turbo intercepts, makes AJAX request
     ↓
Server renders ONLY content (no layout)
     ↓
Turbo swaps <main> content in DOM
     ↓
Sidebar stays, CSS/JS already loaded
     ↓
Content appears
     ↓
Total time: ~50-200ms ✨
```

---

## How Components Stay/Change

```
┌─────────────────────────────────────────────────────────┐
│ Page Load: / (Home)                                     │
├─────────────────────────────────────────────────────────┤
│ NavComponent (sidebar)         │ HomePage content       │
│ • Rendered once                │ • Rendered            │
│ • Stays in DOM                 │                        │
└────────────────────────────────┴────────────────────────┘
                     ↓ User clicks "Calendar"
┌─────────────────────────────────────────────────────────┐
│ Still on same page DOM                                  │
├─────────────────────────────────────────────────────────┤
│ NavComponent (sidebar)         │ Calendar content       │
│ • SAME element                 │ • Swapped via Turbo   │
│ • Not re-rendered              │ • Old content removed  │
│ • No flicker                   │ • New content inserted │
└────────────────────────────────┴────────────────────────┘
                     ↓ User clicks "Profile"
┌─────────────────────────────────────────────────────────┐
│ Still on same page DOM                                  │
├─────────────────────────────────────────────────────────┤
│ NavComponent (sidebar)         │ Profile form           │
│ • STILL same element           │ • Swapped again       │
│ • Never touched                │                        │
└────────────────────────────────┴────────────────────────┘
```

---

## What Makes This Work

### 1. Layout Persistence

```erb
<!-- This wrapper NEVER re-renders after initial load -->
<div class="flex min-h-screen">
  <%= render NavComponent.new(current_user: current_user) %>
  <main class="flex-1">
    <%= yield %>  ← Turbo updates only this
  </main>
</div>
```

### 2. Smart Request Headers

```http
# Initial request (full page)
GET / HTTP/1.1
Accept: text/html

# Turbo navigation
GET /calendars/1 HTTP/1.1
Accept: text/vnd.turbo-stream.html  ← Rails knows to skip layout
```

### 3. Controller Awareness

```ruby
# Rails automatically handles this:
class CalendarsController < ApplicationController
  def show
    # If Accept header is text/vnd.turbo-stream.html:
    #   → Renders only the view (no layout)
    # If Accept header is text/html:
    #   → Renders view + layout
  end
end
```

---

## Visual Timeline

```
TIME: 0ms
┌────────────┐
│ User clicks│
│ "Calendar" │
└────────────┘

TIME: 10ms
┌────────────────────────────┐
│ Turbo intercepts           │
│ Makes AJAX request         │
└────────────────────────────┘

TIME: 50ms
┌────────────────────────────┐
│ Server responds            │
│ (Only content HTML)        │
└────────────────────────────┘

TIME: 60ms
┌────────────────────────────┐
│ Turbo swaps <main> content │
│ Sidebar unchanged         │
└────────────────────────────┘

TIME: 70ms
┌────────────────────────────┐
│ ✅ Done!                   │
│ New content visible        │
│ URL updated in browser     │
│ No page flash              │
└────────────────────────────┘
```

---

## Code Examples

### Application Layout (app/views/layouts/application.html.erb)

```erb
<body>
  <% if authenticated? %>
    <%# Authenticated layout with sidebar %>
    <div class="flex min-h-screen bg-slate-50 font-sans text-slate-900">
      <%= render NavComponent.new(current_user: current_user) %>
      <main class="flex-1">
        <%= yield %>
      </main>
    </div>
  <% else %>
    <%# Unauthenticated layout without sidebar %>
    <main>
      <%= yield %>
    </main>
  <% end %>
</body>
```

### Navigation Component (app/components/nav_component.html.erb)

```erb
<aside class="w-64 bg-white border-r border-slate-200">
  <nav class="flex-1 px-4 space-y-1"> 
    <% Practify.config.sidebar_menu_items.each do |item| %>     
      <%= link_to target_path(item[:path], user_profile), 
        class: "flex items-center gap-3 px-3 py-2",
        data: { 
          turbo_stream: true,  ← This enables SPA behavior
          turbo_prefetch: false
        } do %>
        <%= item[:name] %>    
      <% end %>
    <% end %>
  </nav>
</aside>
```

### Home View (app/views/home/show.html.erb)

```erb
<%# Dashboard Main Container %>
<div class="mx-auto px-2 py-2">
  <%= render HomePage::HomeComponent.new(current_user: @current_user) %>
</div>
```

### Making current_user Available in Views

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include Authentication
  
  helper_method :current_user  ← Makes current_user available in all views

  def current_user
    @current_user ||= Current.session&.user
  end
end
```

---

## Benefits

✅ **Fast**: No full page reloads  
✅ **Smooth**: No white flash between pages  
✅ **Persistent**: Sidebar never reloads  
✅ **SEO Friendly**: Still works with JavaScript disabled  
✅ **Simple**: No React/Vue complexity  
✅ **Native**: Browser back/forward buttons work  
✅ **Progressive**: Falls back to normal links if JS fails  

---

## Debugging Tips

### Check if Turbo is Active

Open browser console and type:

```javascript
Turbo.session
// Should return a Session object if Turbo is loaded
```

### See Turbo Requests in Network Tab

1. Open DevTools → Network tab
2. Click a nav link
3. Look for request with:
   - Accept: `text/vnd.turbo-stream.html`
   - Type: `xhr` (AJAX request)

### Disable Turbo for Testing

Add to a specific link:

```erb
<%= link_to "Calendar", calendar_path, data: { turbo: false } %>
```

Or disable globally in `application.js`:

```javascript
import { Turbo } from "@hotwired/turbo-rails"
Turbo.session.drive = false
```

---

## Common Issues and Solutions

### Issue: Sidebar reloads on every navigation

**Cause**: Links don't have `data: { turbo_stream: true }`

**Solution**: Add Turbo data attributes to nav links

```erb
<%= link_to path, data: { turbo_stream: true } %>
```

### Issue: Page does full reload instead of Turbo navigation

**Cause**: Turbo not loaded or disabled

**Solution**: Check `app/javascript/application.js` has:

```javascript
import "@hotwired/turbo-rails"
```

### Issue: Content doesn't update when clicking nav

**Cause**: Missing controller action or view

**Solution**: Ensure controller responds to requests:

```ruby
class SomeController < ApplicationController
  def show
    # Will automatically render show.html.erb
  end
end
```

---

## Further Reading

- [Turbo Handbook](https://turbo.hotwired.dev/)
- [Turbo Streams](https://turbo.hotwired.dev/handbook/streams)
- [Hotwire Homepage](https://hotwired.dev/)

---

**Last Updated**: January 2026
