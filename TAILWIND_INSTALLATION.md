# Installing TailwindCSS in Rails 8

This guide walks through installing TailwindCSS in a Rails 8 application using the `tailwindcss-rails` gem, including troubleshooting the asset pipeline error.

## Prerequisites

- Rails 8.0 application
- Sprockets asset pipeline
- Ruby 3.2+

## Installation Steps

### 1. Add the TailwindCSS Gem

Add the `tailwindcss-rails` gem to your `Gemfile`:

```ruby
gem "tailwindcss-rails"
```

Place it after `sprockets-rails`:

```ruby
gem "sprockets-rails"
# TailwindCSS for Rails
gem "tailwindcss-rails"
```

### 2. Install Dependencies

Run bundle install:

```bash
bundle install
```

This will install `tailwindcss-rails` and `tailwindcss-ruby` (the underlying TailwindCSS compiler).

### 3. Run the TailwindCSS Installer

Execute the installer command:

```bash
bin/rails tailwindcss:install
```

This command will:
- Create `app/assets/tailwind/application.css` with TailwindCSS directives
- Update `app/views/layouts/application.html.erb` to include the TailwindCSS stylesheet
- Create `Procfile.dev` for running Rails server + TailwindCSS watcher together
- Create `bin/dev` script to start both processes
- Add `app/assets/builds` directory for compiled TailwindCSS assets
- Update `app/assets/config/manifest.js` to include the builds directory
- Build the initial TailwindCSS output

### 4. Configure Asset Pipeline (IMPORTANT - Fixes the Error)

To ensure the asset pipeline can find the compiled TailwindCSS file, add the builds directory to the asset paths.

Edit `config/initializers/assets.rb`:

```ruby
# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
Rails.application.config.assets.paths << Rails.root.join("app/assets/builds")

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w[ admin.js admin.css ]
```

**Key addition:**
```ruby
Rails.application.config.assets.paths << Rails.root.join("app/assets/builds")
```

This tells Rails where to find the compiled `tailwind.css` file.

## Usage

### Development

**Option 1: Use bin/dev (Recommended)**

Start both the Rails server and TailwindCSS watcher together:

```bash
bin/dev
```

**Option 2: Run Separately**

In separate terminal windows:

```bash
# Terminal 1: Rails server
bin/rails server

# Terminal 2: TailwindCSS watcher
bin/rails tailwindcss:watch
```

### Building TailwindCSS

To manually build TailwindCSS once:

```bash
bin/rails tailwindcss:build
```

## Error Encountered and Solution

### The Error

After installation, when starting the Rails server, you may encounter this error:

```
The asset "tailwind.css" is not present in the asset pipeline.
Extracted source (around line #16):
16:    <%= stylesheet_link_tag "tailwind", "data-turbo-track": "reload" %>
```

### Root Cause

The error occurs because:

1. The TailwindCSS installer creates `app/assets/builds/tailwind.css` (the compiled CSS file)
2. The `app/views/layouts/application.html.erb` references it via `stylesheet_link_tag "tailwind"`
3. However, the asset pipeline doesn't know where to find this file because `app/assets/builds` is not in the asset paths

While the installer updates `app/assets/config/manifest.js` with:
```javascript
//= link_tree ../builds
```

This isn't always sufficient. Rails also needs the directory explicitly added to the asset paths in the initializer.

### The Fix

Add the builds directory to the asset paths in `config/initializers/assets.rb`:

```ruby
Rails.application.config.assets.paths << Rails.root.join("app/assets/builds")
```

**Important:** After making this change, **restart your Rails server** for the initializer changes to take effect.

### Why This Works

- `Rails.application.config.assets.paths` tells Rails where to look for assets
- Adding `app/assets/builds` to this array makes the compiled `tailwind.css` discoverable
- When `stylesheet_link_tag "tailwind"` is called, Rails can now find `tailwind.css` in the builds directory

## File Structure

After installation, your project will have:

```
app/
  assets/
    builds/
      tailwind.css          # Compiled TailwindCSS (auto-generated)
      .keep
    config/
      manifest.js           # Updated to include builds directory
    tailwind/
      application.css       # TailwindCSS source file with @import directive
  views/
    layouts/
      application.html.erb  # Updated to include TailwindCSS stylesheet

Procfile.dev               # For running Rails + TailwindCSS watcher
bin/dev                    # Script to start both processes
```

## Verification

After installation and fix:

1. Restart your Rails server
2. Visit any page in your application
3. Check the browser's developer tools → Network tab
4. You should see `tailwind.css` loading successfully (status 200)
5. TailwindCSS utility classes should work in your views

## Example Usage

Now you can use TailwindCSS classes in your views:

```erb
<div class="container mx-auto mt-8 px-4">
  <h1 class="text-3xl font-bold text-blue-600">Welcome</h1>
  <p class="text-gray-700">This is styled with TailwindCSS!</p>
  <button class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">
    Click Me
  </button>
</div>
```

## Troubleshooting

### TailwindCSS changes not reflecting

- Ensure `bin/rails tailwindcss:watch` is running (or use `bin/dev`)
- Check that `app/assets/builds/tailwind.css` exists and has recent timestamp
- Clear browser cache
- Restart Rails server

### Still getting asset pipeline errors

- Verify `config/initializers/assets.rb` has the builds path added
- Ensure you've restarted the Rails server after adding the path
- Check that `app/assets/config/manifest.js` includes `//= link_tree ../builds`
- Verify `app/assets/builds/tailwind.css` exists: `ls -la app/assets/builds/tailwind.css`

### Production deployment

For production, ensure you precompile assets:

```bash
RAILS_ENV=production bin/rails assets:precompile
```

The TailwindCSS build will be included automatically.

## Resources

- [tailwindcss-rails GitHub](https://github.com/rails/tailwindcss-rails)
- [TailwindCSS Documentation](https://tailwindcss.com/docs)
- [Rails Asset Pipeline Guide](https://guides.rubyonrails.org/asset_pipeline.html)



