# How Rails Injects Methods into ERB Views

## What is Ruby Embedded (ERB)?

**Ruby Embedded (ERB)** is a templating system that lets you embed Ruby code inside text files, most commonly HTML. It's part of Ruby's standard library and comes built-in with Ruby itself.

## Where Do View Helper Methods Come From?

When you're writing ERB files in a Rails application, you're not just working with plain Ruby - you have access to methods from different sources:

### 1. **Rails View Helpers**
Methods like `link_to`, `form_with`, `image_tag`, etc. These come from Rails, not ERB itself. Rails automatically makes these available in your view files.

### 2. **Ruby's Standard Library**
Basic Ruby methods are always available since ERB executes Ruby code.

### 3. **Your Application Helpers**
Methods you define in `app/helpers/` directories.

### 4. **Controller Instance Variables**
Variables set in your controller (like `@users`) are accessible in views.

## About `link_to`

`link_to` is specifically for generating HTML links. It doesn't actually make API calls or fetch data from the backend directly - it just creates `<a>` tags that, when clicked, send HTTP requests.

**Example:**
```erb
<%= link_to "Users", users_path %>
```

**Generates:**
```html
<a href="/users">Users</a>
```

When someone clicks that link, *then* the browser makes a request to your backend. The `link_to` method itself just generates the HTML.

---

## How Rails Injects Methods into ERB

### The Magic Behind It

When Rails renders an ERB template, it doesn't just execute it in isolation. It renders it within a **view context** - essentially an object that has all those helper methods available.

### Key Classes to Study

#### 1. **`ActionView::Base`**
This is the main class. Your ERB templates are rendered in the context of an instance of this class (or a subclass). This is where most helper methods live.

#### 2. **`ActionView::Helpers`**
A module containing all the built-in Rails view helpers. These get included into `ActionView::Base`:
- `ActionView::Helpers::UrlHelper` (contains `link_to`)
- `ActionView::Helpers::FormHelper` (contains `form_with`, `text_field`, etc.)
- `ActionView::Helpers::AssetTagHelper` (contains `image_tag`, `javascript_include_tag`, etc.)

#### 3. **`ActionView::Rendering`**
Handles the actual rendering process.

### How It Works (Simplified)

```ruby
# Simplified version of what happens:

class ActionView::Base
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::AssetTagHelper
  # ... many more helper modules
end

# When rendering:
template = ERB.new(File.read("app/views/users/index.html.erb"))
view_context = ActionView::Base.new
rendered_html = template.result(view_context.instance_eval { binding })
```

The `binding` is crucial - it gives ERB access to all instance variables and methods of that `view_context` object.

### Where to Look in Rails Source

- **`actionview/lib/action_view/base.rb`** - The main view class
- **`actionview/lib/action_view/helpers/`** - Directory with all helper modules
- **`actionview/lib/action_view/helpers/url_helper.rb`** - Specifically for `link_to`

### Your Application Helpers

Rails also automatically includes your application helpers:

```ruby
# app/helpers/application_helper.rb
module ApplicationHelper
  def my_custom_method
    "Hello"
  end
end
```

Rails includes this module into the view context, so `<%= my_custom_method %>` works in your ERB files.

---

## Understanding `instance_eval` and `binding`

### The Key Players

#### `instance_eval`
A Ruby method that evaluates code in the context of a specific object. When you call `object.instance_eval { code }`, the code inside the block runs as if it were inside that object - meaning `self` becomes that object, and you have access to all its methods and instance variables.

#### `binding`
A Ruby method that captures the current execution context - all the local variables, instance variables, methods, and `self` at that moment. It's like taking a snapshot of the current scope.

### Why Both Together?

```ruby
view_context.instance_eval { binding }
```

This is saying:
1. Switch into the context of `view_context` object (`instance_eval`)
2. From inside that context, grab the binding (the snapshot of that context)
3. Pass that binding to ERB's `result` method

### What ERB's `result` Method Does

```ruby
template = ERB.new("<%= link_to 'Home', root_path %>")
template.result(some_binding)
```

The `result` method executes the ERB template using the provided binding. The binding determines what variables and methods are available inside the `<%= %>` tags.

### A Simpler Example

```ruby
class Person
  def initialize(name)
    @name = name
  end
  
  def greeting
    "Hello, I'm #{@name}"
  end
end

person = Person.new("Alice")

# Create a binding from inside the person object
person_binding = person.instance_eval { binding }

# Now use that binding with ERB
template = ERB.new("My name is <%= @name %> and <%= greeting %>")
puts template.result(person_binding)
# Output: "My name is Alice and Hello, I'm Alice"
```

Without `instance_eval`, if you just did `binding` at the top level, ERB wouldn't have access to `@name` or the `greeting` method because those belong to the `person` object.

### Why Not Just Pass the Object?

You might wonder why not just:
```ruby
template.result(view_context)  # This won't work!
```

Because `result` specifically expects a `Binding` object, not just any object. The binding is what gives ERB access to the execution context.

### In Rails Context

```ruby
# Simplified Rails rendering
view_context = ActionView::Base.new
view_context.instance_variable_set(:@users, User.all)

template = ERB.new("<%= @users.count %> users")
html = template.result(view_context.instance_eval { binding })
```

Now inside the ERB template, `@users` is accessible because we're executing in a binding that was captured from inside the `view_context` object.

## Key Takeaway

The combination of `instance_eval { binding }` is essentially saying "give me a passport to execute code as if I were inside this object." This is how Rails makes all those helper methods and instance variables available in your ERB templates.

---

## Quick Experiment

You can see what's available in your views by adding this to any ERB file:

```erb
<%= self.class %> <!-- Shows ActionView::Base or similar -->
<%= self.methods.sort %> <!-- Lists all available methods -->
```