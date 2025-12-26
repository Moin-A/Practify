# Rails Controller Creation Guide

A step-by-step guide to creating controllers in Rails with comprehensive routing examples.

---

## Step 1: Create Routes First

Routes define the URLs that users can access and which controller actions handle them. Always start with routes before creating the controller.

### 1.1 Customized Routes (Manual Routes)

Use this when you need specific, custom URL patterns.

**Syntax:**
```ruby
# config/routes.rb
get 'path', to: 'controller#action'
post 'path', to: 'controller#action'
patch 'path', to: 'controller#action'
put 'path', to: 'controller#action'
delete 'path', to: 'controller#action'
```

**Examples:**
```ruby
Rails.application.routes.draw do
  # Simple custom routes
  get 'about', to: 'pages#about'
  get 'contact', to: 'pages#contact'
  post 'contact', to: 'pages#create_contact'
  
  # Custom routes with named path helpers
  get 'signup', to: 'users#new', as: 'signup'
  # Creates signup_path and signup_url helpers
  
  # Custom routes with parameters
  get 'users/:id/profile', to: 'users#profile'
  get 'posts/:year/:month', to: 'posts#archive'
end
```

### 1.2 Resource Routes (RESTful Routes)

Use `resources` to automatically generate all 7 standard RESTful routes.

**Full Resources:**
```ruby
resources :posts
```

This creates:
| HTTP Verb | Path | Controller#Action | Named Route Helper | Purpose |
|-----------|------|-------------------|-------------------|---------|
| GET | /posts | posts#index | posts_path | List all posts |
| GET | /posts/new | posts#new | new_post_path | Show form to create new post |
| POST | /posts | posts#create | posts_path | Create a new post |
| GET | /posts/:id | posts#show | post_path(:id) | Show a specific post |
| GET | /posts/:id/edit | posts#edit | edit_post_path(:id) | Show form to edit post |
| PATCH/PUT | /posts/:id | posts#update | post_path(:id) | Update a specific post |
| DELETE | /posts/:id | posts#destroy | post_path(:id) | Delete a specific post |

**Limited Resources:**
```ruby
# Only specific actions
resources :posts, only: [:index, :show, :create]

# Exclude specific actions
resources :posts, except: [:destroy]
```

**Singular Resource (No ID needed):**
```ruby
# For resources where there's only one (like user profile, account settings)
resource :profile
resource :session
resource :registration, only: [:new, :create]
```

Singular resource creates:
| HTTP Verb | Path | Controller#Action | Named Route Helper |
|-----------|------|-------------------|-------------------|
| GET | /profile/new | profiles#new | new_profile_path |
| POST | /profile | profiles#create | profile_path |
| GET | /profile | profiles#show | profile_path |
| GET | /profile/edit | profiles#edit | edit_profile_path |
| PATCH/PUT | /profile | profiles#update | profile_path |
| DELETE | /profile | profiles#destroy | profile_path |

### 1.3 Member Routes

Add custom routes that act on a **specific member** (requires an ID).

```ruby
resources :posts do
  member do
    post :publish      # POST /posts/:id/publish
    patch :archive     # PATCH /posts/:id/archive
    get :preview       # GET /posts/:id/preview
  end
end

# Shorthand for single member route
resources :posts do
  post :publish, on: :member  # POST /posts/:id/publish
end
```

**Creates:**
- `publish_post_path(@post)` → `/posts/1/publish`
- `archive_post_path(@post)` → `/posts/1/archive`
- `preview_post_path(@post)` → `/posts/1/preview`

### 1.4 Collection Routes

Add custom routes that act on the **entire collection** (no ID required).

```ruby
resources :posts do
  collection do
    get :archived      # GET /posts/archived
    post :bulk_delete  # POST /posts/bulk_delete
    get :search        # GET /posts/search
  end
end

# Shorthand for single collection route
resources :posts do
  get :search, on: :collection  # GET /posts/search
end
```

**Creates:**
- `archived_posts_path` → `/posts/archived`
- `bulk_delete_posts_path` → `/posts/bulk_delete`
- `search_posts_path` → `/posts/search`

### 1.5 Nested Routes

Use nested routes to represent parent-child relationships.

```ruby
resources :users do
  resources :posts
end
```

**Creates routes like:**
- `GET /users/:user_id/posts` → `user_posts_path(@user)`
- `GET /users/:user_id/posts/new` → `new_user_post_path(@user)`
- `POST /users/:user_id/posts` → `user_posts_path(@user)`
- `GET /users/:user_id/posts/:id` → `user_post_path(@user, @post)`

**Shallow Nesting (Recommended):**
```ruby
resources :users do
  resources :posts, shallow: true
end

# Or with a block
resources :users, shallow: true do
  resources :posts
end
```

Creates:
- `GET /users/:user_id/posts` (nested - needs parent context)
- `GET /users/:user_id/posts/new` (nested - needs parent context)
- `POST /users/:user_id/posts` (nested - needs parent context)
- `GET /posts/:id` (shallow - doesn't need parent)
- `PATCH /posts/:id` (shallow)
- `DELETE /posts/:id` (shallow)

**Multiple Nesting Levels:**
```ruby
resources :users do
  resources :posts do
    resources :comments
  end
end

# Access: /users/:user_id/posts/:post_id/comments
# Helper: user_post_comments_path(@user, @post)
```

**⚠️ Best Practice:** Don't nest more than 1 level deep. Use shallow nesting instead.

---

## Step 2: Create the Controller

After defining routes, create the controller file.

### 2.1 Using Rails Generator

```bash
# Generate controller with actions
rails generate controller Posts index show new edit

# Generate empty controller
rails generate controller Posts

# Generate with namespace
rails generate controller Admin::Posts
```

### 2.2 Manual Creation

Create file: `app/controllers/posts_controller.rb`

```ruby
class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :require_authentication, except: [:index, :show]
  
  # GET /posts
  def index
    @posts = Post.all
  end
  
  # GET /posts/:id
  def show
  end
  
  # GET /posts/new
  def new
    @post = Post.new
  end
  
  # POST /posts
  def create
    @post = Post.new(post_params)
    
    if @post.save
      redirect_to @post, notice: 'Post was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  # GET /posts/:id/edit
  def edit
  end
  
  # PATCH/PUT /posts/:id
  def update
    if @post.update(post_params)
      redirect_to @post, notice: 'Post was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  # DELETE /posts/:id
  def destroy
    @post.destroy
    redirect_to posts_path, notice: 'Post was successfully destroyed.'
  end
  
  private
    def set_post
      @post = Post.find(params[:id])
    end
    
    def post_params
      params.require(:post).permit(:title, :body, :published)
    end
end
```

---

## Step 3: Create Views

Create corresponding view files in `app/views/controller_name/`

### 3.1 Required Views for Standard Actions

```
app/views/posts/
├── index.html.erb    # List view
├── show.html.erb     # Detail view
├── new.html.erb      # Create form
├── edit.html.erb     # Edit form
└── _form.html.erb    # Shared form partial (optional)
```

### 3.2 Example View (new.html.erb)

```erb
<h1>New Post</h1>

<%= form_with model: @post do |form| %>
  <% if @post.errors.any? %>
    <div style="color: red">
      <h2><%= pluralize(@post.errors.count, "error") %> prohibited this post from being saved:</h2>
      <ul>
        <% @post.errors.each do |error| %>
          <li><%= error.full_message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div>
    <%= form.label :title %>
    <%= form.text_field :title %>
  </div>

  <div>
    <%= form.label :body %>
    <%= form.text_area :body %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>

<%= link_to "Back to posts", posts_path %>
```

---

## Step 4: Create Tests (RSpec)

Create request specs: `spec/requests/posts_spec.rb`

```ruby
require 'rails_helper'

RSpec.describe "Posts", type: :request do
  describe "GET /posts" do
    it "returns http success" do
      get posts_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /posts" do
    context "with valid parameters" do
      let(:valid_attributes) do
        { post: { title: "Test Post", body: "Test Body" } }
      end

      it "creates a new post" do
        expect {
          post posts_path, params: valid_attributes
        }.to change(Post, :count).by(1)
      end

      it "redirects to the created post" do
        post posts_path, params: valid_attributes
        expect(response).to redirect_to(Post.last)
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) do
        { post: { title: "", body: "" } }
      end

      it "does not create a new post" do
        expect {
          post posts_path, params: invalid_attributes
        }.not_to change(Post, :count)
      end

      it "returns unprocessable entity status" do
        post posts_path, params: invalid_attributes
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
```

---

## Complete Example: Registration Controller

Here's a complete real-world example from our application:

### Routes
```ruby
# config/routes.rb
Rails.application.routes.draw do
  resource :registration, only: [:new, :create]
end
```

### Controller
```ruby
# app/controllers/registrations_controller.rb
class RegistrationsController < ApplicationController
  allow_unauthenticated_access

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    
    if @user.save
      start_new_session_for @user
      redirect_to root_path, notice: "Welcome! You have signed up successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def user_params
      params.require(:user).permit(:email_address, :password, :password_confirmation)
    end
end
```

### View
```erb
<!-- app/views/registrations/new.html.erb -->
<h1>Sign Up</h1>

<%= form_with model: @user, url: registration_path do |form| %>
  <% if @user.errors.any? %>
    <div style="color:red">
      <h2><%= pluralize(@user.errors.count, "error") %> prohibited this user from being saved:</h2>
      <ul>
        <% @user.errors.each do |error| %>
          <li><%= error.full_message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <%= form.email_field :email_address, required: true, placeholder: "Email" %>
  <%= form.password_field :password, required: true, placeholder: "Password" %>
  <%= form.password_field :password_confirmation, required: true, placeholder: "Confirm Password" %>
  <%= form.submit "Sign up" %>
<% end %>
```

---

## Routing Cheat Sheet

### Quick Reference Table

| Route Type | Syntax | Use Case |
|------------|--------|----------|
| Custom | `get 'path', to: 'controller#action'` | One-off custom URLs |
| Resources | `resources :posts` | Standard CRUD operations |
| Singular Resource | `resource :profile` | One-per-user resources |
| Nested | `resources :users do resources :posts end` | Parent-child relationships |
| Member | `post :publish, on: :member` | Action on specific record |
| Collection | `get :search, on: :collection` | Action on entire collection |
| Namespace | `namespace :admin do resources :posts end` | Organize by section |

### Helpful Rails Commands

```bash
# View all routes
rails routes

# View routes for specific controller
rails routes -c posts

# View routes matching pattern
rails routes -g user

# Generate controller
rails generate controller ControllerName action1 action2

# Destroy controller
rails destroy controller ControllerName
```

---

## Best Practices

1. **Routes First:** Always define routes before creating controllers
2. **RESTful by Default:** Use `resources` for standard CRUD operations
3. **Limit Nesting:** Don't nest routes more than 1 level deep
4. **Use Shallow Nesting:** For nested resources that don't always need parent context
5. **Strong Parameters:** Always use strong parameters in controllers
6. **Before Actions:** Use `before_action` for shared logic
7. **Meaningful Names:** Use clear, descriptive action names
8. **Test Everything:** Write request specs for all controller actions
9. **Handle Errors:** Always handle validation failures with proper status codes
10. **Follow Conventions:** Stick to Rails conventions unless you have a good reason not to

---

## Common Patterns

### Pattern 1: Namespaced Admin Controllers
```ruby
# config/routes.rb
namespace :admin do
  resources :posts
end

# app/controllers/admin/posts_controller.rb
class Admin::PostsController < ApplicationController
  before_action :require_admin
end
```

### Pattern 2: Concerns for Shared Logic
```ruby
# app/controllers/concerns/authentication.rb
module Authentication
  extend ActiveSupport::Concern
  
  included do
    before_action :require_authentication
  end
end

# Use in controller
class PostsController < ApplicationController
  include Authentication
end
```

### Pattern 3: Singular Resource for User-Specific Data
```ruby
# config/routes.rb
resource :dashboard, only: [:show]
resource :settings, only: [:show, :update]

# Each user has ONE dashboard, ONE settings page
```

---

## Troubleshooting

### Issue: "No route matches"
- Check `rails routes` to see if route exists
- Verify HTTP verb matches (GET vs POST)
- Check route parameter names match

### Issue: "Couldn't find [Model] with 'id'="
- Ensure ID parameter is being passed correctly
- Check `before_action` is finding the correct record
- Verify route uses `:id` parameter

### Issue: "Action not found"
- Ensure controller has the action method defined
- Check method name matches route exactly
- Verify controller file is saved

---

## Additional Resources

- [Rails Routing Guide](https://guides.rubyonrails.org/routing.html)
- [Rails Controllers Guide](https://guides.rubyonrails.org/action_controller_overview.html)
- [RESTful Design](https://restfulapi.net/)

---

*Generated for Practify - Rails 8 Application*

