# ViewComponent Creation Pattern

This document outlines the step-by-step pattern for creating ViewComponents in this Rails application, following the established conventions.

## Pattern Overview

To create a reusable ViewComponent that can be used with `content_for` for deferred rendering, follow these steps:

## Step 1: Create the Component Class

Create a Ruby class file in `app/components/`:

**File:** `app/components/[COMPONENT_NAME]_component.rb`

```ruby
class [ComponentName]Component < ApplicationComponent
  def initialize([options])
    # Initialize instance variables from options
  end

  # Add methods that will be used in the template
  def [method_name]
    # Return values for template
  end
end
```

## Step 2: Create the Component Template

Create the corresponding HTML template file:

**File:** `app/components/[COMPONENT_NAME]_component.html.erb`

```erb
<!-- HTML/ERB template that uses component methods -->
<%= [method_name] %>
```

## Step 3: Create the Helper Module

Create a helper module in `app/helpers/`:

**File:** `app/helpers/[component_name]_helper.rb`

```ruby
module [ComponentName]Helper
  def [component_name](options = {})
    content_for(:[content_key]) do
      component = options.delete(:component) || [ComponentName]Component
      render component.new(**options)
    end
  end

  def render_[component_name]
    content_for(:[content_key]) || render([ComponentName]Component.new)
  end
end
```

## Step 4: Usage in Views

In your ERB view files, call the helper method:

```erb
<%= [component_name] [option1]: value1, [option2]: value2 %>
```

## Step 5: Render in Layout

In your layout file (e.g., `app/views/layouts/application.html.erb`), render the stored content:

```erb
<%= render_[component_name] %>
```

## Example: OpenGraphTagsComponent

### Component Class
**File:** `app/components/open_graph_tags_component.rb`
```ruby
class OpenGraphTagsComponent < ApplicationComponent
  def initialize(title: nil, turbo_native_title: nil, description: nil, image: nil)
    @title = title
    @turbo_native_title = turbo_native_title
    @description = description
    @image = image
  end

  def title
    # Logic to determine title
  end
end
```

### Component Template
**File:** `app/components/open_graph_tags_component.html.erb`
```erb
<title><%= title %></title>
<%= tag.meta property: "og:title", content: title %>
```

### Helper Module
**File:** `app/helpers/open_graph_tags_helper.rb`
```ruby
module OpenGraphTagsHelper
  def open_graph_tags(options = {})
    content_for(:open_graph_tags) do
      component = options.delete(:component) || OpenGraphTagsComponent
      render component.new(**options)
    end
  end

  def render_open_graph_tags
    content_for(:open_graph_tags) || render(OpenGraphTagsComponent.new)
  end
end
```

### Usage in View
```erb
<%= open_graph_tags title: t(".title_og"), description: t(".description_og") %>
```

### Render in Layout
```erb
<%= render_open_graph_tags %>
```

## Setup Prompt for ViewComponent Infrastructure

Use this template to set up the initial ViewComponent infrastructure in a new project:

```
Set up ViewComponent infrastructure in this Rails project:

1. Add required gems to Gemfile:
   - gem "view_component"
   - gem "classy-yaml"
   - Run `bundle install`

2. Create the components directory:
   - Create `app/components/`

3. Create the base ApplicationComponent:
   - File: `app/components/application_component.rb`
   - Inherit from `ViewComponent::Base`
   - Include `Classy::Yaml::ComponentHelpers` (for translations)
   - Include `UrlHelpersWithDefaultUrlOptions` (for URL helpers)

Code for application_component.rb:
class ApplicationComponent < ViewComponent::Base
  include Classy::Yaml::ComponentHelpers
  include UrlHelpersWithDefaultUrlOptions
end
```

## Template Prompt for Creating New Components

Use this template when creating a new component:

```
Create a ViewComponent following this pattern:

1. Create component class: app/components/[COMPONENT_NAME]_component.rb
   - Inherit from ApplicationComponent
   - Add initialize method with options
   - Add methods for template use

2. Create component template: app/components/[COMPONENT_NAME]_component.html.erb
   - Write HTML/ERB using component methods

3. Create helper module: app/helpers/[component_name]_helper.rb
   - Add [component_name] method that uses content_for(:[content_key])
   - Add render_[component_name] method to retrieve content
   - Initialize [ComponentName]Component with passed options

4. Usage: Call <%= [component_name] [options] %> in views
5. Render: Call <%= render_[component_name] %> in layout

Component name: [COMPONENT_NAME]
Content key: [content_key]
Options: [list of options]
```

## Notes

- Rails automatically includes all modules in `app/helpers/` into the view context
- No explicit `include` statement is needed
- The `content_for` pattern allows deferred rendering (store in view, render in layout)
- ViewComponent automatically finds the corresponding `.html.erb` template file
