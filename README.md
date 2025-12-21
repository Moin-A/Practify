# Practify

A Rails 8 application with Hotwire (Turbo & Stimulus), PostgreSQL, and Sidekiq.

## Prerequisites

- Ruby (see `.ruby-version`)
- PostgreSQL
- Redis (required for Sidekiq)

## Setup

1. Install dependencies:
   ```bash
   bundle install
   ```

2. Set up the database:
   ```bash
   rails db:create
   rails db:migrate
   ```

3. Start Redis (required for Sidekiq):
   ```bash
   # macOS with Homebrew
   brew services start redis

   # Or run directly
   redis-server
   ```

4. Start the Rails server:
   ```bash
   rails server
   ```

5. In a separate terminal, start Sidekiq:
   ```bash
   bundle exec sidekiq
   ```

## Features

- **Rails 8**: Latest Rails framework
- **Hotwire**: Turbo and Stimulus for modern, reactive web applications
- **PostgreSQL**: Robust relational database
- **Sidekiq**: Background job processing with Redis

## Sidekiq Web UI

Access the Sidekiq web interface at: `http://localhost:3000/sidekiq`

**Note**: In production, you should protect this route with authentication!

## Configuration

### Environment Variables

- `REDIS_URL`: Redis connection URL (default: `redis://localhost:6379/0`)
- `DATABASE_URL`: PostgreSQL connection URL (optional)
- `RAILS_MAX_THREADS`: Maximum number of threads (default: 5)

## Running Tests

```bash
rails test
```

## Background Jobs

ActiveJob is configured to use Sidekiq. Create jobs in `app/jobs/`:

```ruby
class ExampleJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Your job logic here
  end
end
```

Enqueue jobs with:
```ruby
ExampleJob.perform_later(args)
```
# Practify
