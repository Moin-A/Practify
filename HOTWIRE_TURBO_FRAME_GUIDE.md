# Hotwire Turbo Frame Guide

A comprehensive guide to understanding and using Turbo Frames in Rails applications.

## Table of Contents
1. [What are Turbo Frames?](#what-are-turbo-frames)
2. [How Turbo Frames Work](#how-turbo-frames-work)
3. [Basic Setup](#basic-setup)
4. [Updating Forms](#updating-forms)
5. [Updating Sections](#updating-sections)
6. [Turbo Frame Options](#turbo-frame-options)
7. [Complete Flow Example](#complete-flow-example)
8. [Use Cases](#use-cases)
9. [Common Patterns](#common-patterns)
10. [Troubleshooting](#troubleshooting)

---

## What are Turbo Frames?

Turbo Frames are a way to update **specific sections** of a page without reloading the entire page. They create isolated, updatable sections that can be replaced independently.

### Key Benefits:
- ✅ No full page reload
- ✅ Faster perceived performance
- ✅ Preserves scroll position
- ✅ Maintains page context
- ✅ Works without custom JavaScript

---

## How Turbo Frames Work

### The Flow:

```
1. User clicks a link/button with data-turbo-frame="frame_id"
   ↓
2. Turbo intercepts the click (prevents default navigation)
   ↓
3. Makes an AJAX request to the server
   ↓
4. Server returns FULL HTML page (with layout)
   ↓
5. Turbo searches response for <turbo-frame id="frame_id">
   ↓
6. Extracts ONLY that frame's content
   ↓
7. Replaces existing frame on page (no full reload)
   ↓
8. Rest of page stays unchanged
```

### Important Points:
- **Server still renders full page** - but Turbo only uses the frame content
- **Only the matching frame updates** - everything else stays the same
- **No JavaScript needed** - Turbo handles everything automatically
- **Works with forms, links, buttons** - any element can target a frame

---

## Basic Setup

### 1. Create a Turbo Frame in Your View

```erb
<!-- app/views/pages/index.html.erb -->
<%= turbo_frame_tag "my_frame" do %>
  <div>
    <p>This content will be updatable</p>
    <%= link_to "Update", update_path, data: { turbo_frame: "my_frame" } %>
  </div>
<% end %>
```

### 2. Create a Link/Button That Targets the Frame

```erb
<%= link_to "Update Section", 
    update_path, 
    data: { turbo_frame: "my_frame" } %>
```

### 3. Ensure Response Contains Matching Frame

```erb
<!-- app/views/pages/update.html.erb -->
<%= turbo_frame_tag "my_frame" do %>
  <div>
    <p>Updated content!</p>
  </div>
<% end %>
```

**Key Rule:** The response HTML must contain a `<turbo-frame id="my_frame">` for Turbo to find and extract it.

---

## Updating Forms

### Pattern 1: Form Inside Frame

```erb
<!-- Initial form -->
<%= turbo_frame_tag "user_form" do %>
  <%= form_with model: @user do |f| %>
    <%= f.text_field :name %>
    <%= f.submit "Save" %>
  <% end %>
<% end %>
```

**Controller:**
```ruby
def create
  @user = User.new(user_params)
  
  if @user.save
    # Response must include the frame
    render :show  # show.html.erb has turbo_frame_tag "user_form"
  else
    render :new, status: :unprocessable_entity
  end
end
```

**Response view:**
```erb
<!-- app/views/users/show.html.erb -->
<%= turbo_frame_tag "user_form" do %>
  <div class="success-message">
    User created successfully!
  </div>
<% end %>
```

### Pattern 2: Form Submits to Frame

```erb
<%= turbo_frame_tag "new_user_form" do %>
  <%= form_with model: User.new, 
      data: { turbo_frame: "new_user_form" } do |f| %>
    <%= f.text_field :name %>
    <%= f.submit "Create" %>
  <% end %>
<% end %>
```

**Note:** Adding `data: { turbo_frame: "new_user_form" }` to the form ensures the form submission targets the frame.

---

## Updating Sections

### Example: Filtering Products

```erb
<!-- Product list section -->
<%= turbo_frame_tag "products" do %>
  <div class="filters">
    <%= link_to "Electronics", 
        products_path(category: "electronics"),
        data: { turbo_frame: "products" } %>
    <%= link_to "Clothing", 
        products_path(category: "clothing"),
        data: { turbo_frame: "products" } %>
  </div>
  
  <div class="product-list">
    <% @products.each do |product| %>
      <%= render product %>
    <% end %>
  </div>
<% end %>
```

**Controller:**
```ruby
def index
  @products = Product.where(category: params[:category])
  # Renders index.html.erb which has turbo_frame_tag "products"
end
```

**Result:** Only the products section updates, filters and other page content stay unchanged.

---

## Turbo Frame Options

### 1. `data-turbo-frame` (Target Frame)

Specifies which frame to update:

```erb
<%= link_to "Update", path, 
    data: { turbo_frame: "my_frame" } %>
```

**Options:**
- `"my_frame"` - Updates frame with id "my_frame"
- `"_self"` - Updates the frame containing the link
- `"_top"` - Breaks out of frames, updates entire page

### 2. `data-turbo-action` (URL Behavior)

Controls whether the browser URL updates:

```erb
<%= link_to "Update", path,
    data: { 
      turbo_frame: "my_frame",
      turbo_action: "advance"  # or "replace"
    } %>
```

**Options:**
- `"advance"` (default for links)
  - ✅ Updates browser URL
  - ✅ Creates history entry
  - ✅ Query params visible in address bar
  - ✅ Back button works
  - ✅ Can bookmark/share URL

- `"replace"` (default for frames)
  - ❌ Doesn't update URL
  - ❌ No history entry
  - ❌ Query params not visible
  - ⚡ Faster (no URL manipulation)
  - 💡 Use for temporary/interactive updates

**When to use each:**
- Use `advance` when:
  - User should be able to bookmark the state
  - URL should reflect current selection/filter
  - Back button should work
  - Sharing URL is important

- Use `replace` when:
  - Temporary UI updates
  - Internal navigation
  - Don't want to pollute browser history
  - Performance is critical

### 3. `data-turbo-method` (HTTP Method)

For forms and buttons:

```erb
<%= button_to "Delete", 
    user_path(@user),
    method: :delete,
    data: { turbo_frame: "user_list" } %>
```

### 4. `loading` Attribute

Show loading state:

```erb
<%= turbo_frame_tag "content", loading: "lazy" do %>
  <!-- Content loads when frame becomes visible -->
<% end %>
```

**Options:**
- `"eager"` (default) - Loads immediately
- `"lazy"` - Loads when frame enters viewport

---

## Complete Flow Example

### Scenario: Slot Selection (Your Use Case)

#### Step 1: Create Frame in View

```erb
<!-- app/components/home_page/client_component.html.erb -->
<%= helpers.turbo_frame_tag "quick_book" do %>
  <div class="slots">
    <% next_day_available_slots.each do |slot| %>
      <%= helpers.link_to slot[:time], 
          "#{helpers.root_path}?selected_slot_id=#{slot[:id]}", 
          data: { 
            turbo_frame: "quick_book",
            turbo_action: "advance" 
          },
          class: "slot-button" %>
    <% end %>
  </div>
  
  <% if selected_slot.present? %>
    <%= helpers.button_to "Confirm Slot", 
        confirm_path(@calendar, selected_slot),
        method: :post %>
  <% end %>
<% end %>
```

#### Step 2: User Clicks Slot

```
User clicks "10:00 AM" link
    ↓
URL: /?selected_slot_id=123
    ↓
Turbo intercepts (sees data-turbo-frame="quick_book")
    ↓
Makes GET request to /?selected_slot_id=123
```

#### Step 3: Server Processes Request

```ruby
# app/controllers/home_controller.rb
def show
  @current_user = current_user
  @selected_slot_id = params[:selected_slot_id]  # = "123"
  # Renders home/show.html.erb
end
```

```erb
<!-- app/views/home/show.html.erb -->
<%= render HomePage::HomeComponent.new(
  current_user: @current_user,
  selected_slot_id: @selected_slot_id
) %>
```

#### Step 4: Server Returns Full HTML

```html
<!DOCTYPE html>
<html>
  <head>...</head>
  <body>
    <nav>...</nav>
    <main>
      <div>
        <turbo-frame id="quick_book">  ← Turbo looks for this!
          <div class="slots">
            <a class="slot-button selected">10:00 AM</a>
            <a class="slot-button">11:00 AM</a>
          </div>
          <button>Confirm Slot</button>  ← Now visible!
        </turbo-frame>
      </div>
    </main>
  </body>
</html>
```

#### Step 5: Turbo Extracts Frame

```
Turbo searches response HTML
    ↓
Finds <turbo-frame id="quick_book">
    ↓
Extracts content inside frame
    ↓
Ignores everything else (layout, nav, etc.)
```

#### Step 6: Turbo Updates Page

```
Replaces existing <turbo-frame id="quick_book">
    ↓
Only that section updates
    ↓
Rest of page unchanged (no reload)
    ↓
Browser URL updates to /?selected_slot_id=123 (because of advance)
```

---

## Use Cases

### 1. **Filtering & Search**
Update only the results section when filters change.

```erb
<%= turbo_frame_tag "search_results" do %>
  <%= form_with url: search_path, 
      data: { turbo_frame: "search_results" } do |f| %>
    <%= f.search_field :query %>
    <%= f.submit "Search" %>
  <% end %>
  
  <div class="results">
    <% @results.each do |result| %>
      <%= render result %>
    <% end %>
  </div>
<% end %>
```

### 2. **Shopping Cart**
Update cart widget without reloading page.

```erb
<%= turbo_frame_tag "cart" do %>
  <div class="cart-items">
    <% @cart.items.each do |item| %>
      <%= render item %>
    <% end %>
  </div>
  <div class="cart-total">
    Total: <%= @cart.total %>
  </div>
<% end %>
```

### 3. **Tab Navigation**
Switch tabs without page reload.

```erb
<%= turbo_frame_tag "tab_content" do %>
  <%= link_to "Tab 1", tab_path(id: 1),
      data: { turbo_frame: "tab_content" } %>
  <%= link_to "Tab 2", tab_path(id: 2),
      data: { turbo_frame: "tab_content" } %>
  
  <div class="content">
    <%= render @tab_content %>
  </div>
<% end %>
```

### 4. **Form Validation**
Show errors inline without losing form state.

```erb
<%= turbo_frame_tag "user_form" do %>
  <%= form_with model: @user,
      data: { turbo_frame: "user_form" } do |f| %>
    <%= f.text_field :email %>
    <% if @user.errors[:email].any? %>
      <div class="error"><%= @user.errors[:email].first %></div>
    <% end %>
    <%= f.submit "Save" %>
  <% end %>
<% end %>
```

### 5. **Pagination**
Update only the content area when paginating.

```erb
<%= turbo_frame_tag "posts" do %>
  <div class="posts">
    <% @posts.each do |post| %>
      <%= render post %>
    <% end %>
  </div>
  
  <%= paginate @posts, 
      params: { turbo_frame: "posts" } %>
<% end %>
```

### 6. **Modal Forms**
Open/close modals without page reload.

```erb
<%= turbo_frame_tag "modal" do %>
  <% if @show_modal %>
    <div class="modal">
      <%= form_with model: @item do |f| %>
        <!-- form fields -->
      <% end %>
    </div>
  <% end %>
<% end %>
```

---

## Common Patterns

### Pattern 1: Nested Frames

```erb
<%= turbo_frame_tag "outer" do %>
  <h1>Outer Frame</h1>
  
  <%= turbo_frame_tag "inner" do %>
    <p>Inner Frame</p>
    <%= link_to "Update Inner", inner_path,
        data: { turbo_frame: "inner" } %>
  <% end %>
<% end %>
```

### Pattern 2: Frame with Loading State

```erb
<%= turbo_frame_tag "content", loading: "lazy" do %>
  <div class="loading">Loading...</div>
<% end %>
```

### Pattern 3: Breaking Out of Frame

```erb
<%= link_to "Full Page", path,
    data: { turbo_frame: "_top" } %>
```

This breaks out of all frames and navigates the entire page.

### Pattern 4: Self-Contained Frame

```erb
<%= turbo_frame_tag "widget" do %>
  <%= link_to "Update", update_path,
      data: { turbo_frame: "_self" } %>
  <!-- Updates the frame containing this link -->
<% end %>
```

---

## Troubleshooting

### Problem: Frame Not Updating

**Symptoms:** Clicking link does nothing, or full page reloads.

**Solutions:**
1. ✅ Check response contains matching `<turbo-frame id="...">`
2. ✅ Verify `data-turbo-frame` attribute matches frame id
3. ✅ Check browser console for JavaScript errors
4. ✅ Ensure Turbo is loaded: `import "@hotwired/turbo-rails"`

### Problem: Wrong Content in Frame

**Symptoms:** Frame updates but shows wrong content.

**Solutions:**
1. ✅ Verify controller action renders correct view
2. ✅ Check view has matching `turbo_frame_tag`
3. ✅ Ensure frame id matches in both request and response

### Problem: Query Params Not Visible

**Symptoms:** URL doesn't update when clicking links.

**Solutions:**
1. ✅ Add `data: { turbo_action: "advance" }` to link
2. ✅ Default for frames is `"replace"` (doesn't update URL)

### Problem: Form Not Submitting to Frame

**Symptoms:** Form submission causes full page reload.

**Solutions:**
1. ✅ Add `data: { turbo_frame: "frame_id" }` to form
2. ✅ Ensure form action renders view with matching frame
3. ✅ Check form method (GET/POST) matches route

### Problem: Frame Content Not Found

**Symptoms:** Frame becomes empty or shows error.

**Solutions:**
1. ✅ Verify response HTML contains the frame
2. ✅ Check frame id spelling (case-sensitive)
3. ✅ Ensure server returns 200 status (not redirect)

---

## Best Practices

### ✅ Do:
- Use descriptive frame IDs: `"user_form"` not `"frame1"`
- Always include matching frame in response
- Use `advance` for state that should be bookmarkable
- Use `replace` for temporary UI updates
- Test with browser DevTools Network tab

### ❌ Don't:
- Don't nest frames unnecessarily (can cause issues)
- Don't forget to include frame in response
- Don't use frames for entire page navigation
- Don't mix Turbo Frames with Turbo Streams unnecessarily
- Don't forget to handle errors in frame responses

---

## Quick Reference

### Creating a Frame
```erb
<%= turbo_frame_tag "my_frame" do %>
  <!-- content -->
<% end %>
```

### Targeting a Frame
```erb
<%= link_to "Update", path,
    data: { turbo_frame: "my_frame" } %>
```

### Form in Frame
```erb
<%= form_with model: @model,
    data: { turbo_frame: "my_frame" } do |f| %>
  <!-- fields -->
<% end %>
```

### URL Updates
```erb
<%= link_to "Update", path,
    data: { 
      turbo_frame: "my_frame",
      turbo_action: "advance"  # or "replace"
    } %>
```

---

## Summary

Turbo Frames allow you to:
- ✅ Update specific sections without full page reload
- ✅ Create SPA-like experiences
- ✅ Maintain page context and state
- ✅ Improve perceived performance
- ✅ Work without custom JavaScript

**Remember:** The server still renders the full page, but Turbo extracts only the matching frame content and updates just that section on the page.

---

## Additional Resources

- [Turbo Frames Documentation](https://turbo.hotwired.dev/handbook/frames)
- [Rails + Hotwire Guide](https://hotwired.dev/)
- [Turbo Handbook](https://turbo.hotwired.dev/handbook/introduction)

---

*Last updated: Based on Rails 7+ with Hotwire Turbo*
