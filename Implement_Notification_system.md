# Hexagonal Notification System (Omnes + Noticed)

This plan implements a "Piling and Publishing" pattern for appointment reminders, following Hexagonal Architecture principles to keep the domain logic separated from the notification infrastructure.

## Proposed Changes

### 1. Domain & Core (The Hexagon)
Logic that is independent of external systems (like emails or jobs).

#### [NEW] [appointment.rb](file:///Users/apple/railsdevs.com/app/models/appointment.rb)
The core entity.
```ruby
class Appointment < ApplicationRecord
  # publisher (e.g., therapist) and subscriber (e.g., client)
  belongs_to :publisher, class_name: "User"
  belongs_to :subscriber, class_name: "User"

  scope :pending, -> { where(status: :pending) }
end