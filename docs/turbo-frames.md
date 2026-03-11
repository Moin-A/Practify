## Turbo Frames – usage guide

This app makes heavy use of Turbo Frames for partial-page updates (e.g. booking slots, opening payment modals). This document captures the key patterns and the “Content missing” gotcha.

---

### 1. Basic `turbo_frame_tag` usage

Wrap the part of the page you want to be replaceable:

```erb
<%= turbo_frame_tag "interview_slots" do %>
  <!-- content that can be replaced -->
<% end %>
```

- **Frame id** must be **globally unique** on the page (e.g. `"interview_slots"`, `"new_slot_form"`, `"payment_modal"`).
- Anything rendered later with the same frame id can **replace** this content without a full-page reload.

---

### 2. Navigating *into* a frame (`data-turbo-frame`)

To load a new URL **inside** an existing frame, use `data-turbo-frame` on links/buttons:

```erb
<%= link_to calendar_schedule_path(@calendar),
      data: { turbo_frame: "interview_slots" } do %>
  See slots
<% end %>
```

Behavior:

- Turbo issues a normal GET to the URL.
- It expects the **response HTML** to contain:

  ```erb
  <turbo-frame id="interview_slots"> ... </turbo-frame>
  ```

- Turbo then:
  - Extracts that `<turbo-frame id="interview_slots">` from the response.
  - Replaces the **current page’s** `interview_slots` frame with the response’s frame content.
  - Leaves the rest of the page unchanged (no full navigation).

If the response **does not** contain a frame with the requested id, Turbo raises **“Content missing”**.

---

### 3. The “Content missing” gotcha (and fix)

**Problem pattern**

```erb
<%= link_to new_calendar_slot_checkout_path(calendar, slot),
      data: { turbo_frame: "payment_modal" } %>
```

- This tells Turbo: “GET that URL, but only update the `payment_modal` frame on the current page.”
- If the controller action (`CheckoutsController#new` in this case) renders:

```erb
<!-- checkouts/new.html.erb (BAD for frame nav) -->
<!-- NO turbo_frame_tag "payment_modal" here -->
...full page / modal markup without a frame...
```

Turbo cannot find `<turbo-frame id="payment_modal">` in the response and shows **“Content missing”**.

**Correct pattern**

1. **Wrap the response view in a matching frame:**

```erb
<!-- checkouts/new.html.erb -->
<%= turbo_frame_tag "payment_modal" do %>
  <!-- payment modal content -->
<% end %>
```

2. **Make the controller frame-aware:**

```ruby
def new
  # set up instance variables...

  respond_to do |format|
    format.html do
      # For Turbo Frame requests, render without layout so only the frame HTML is returned.
      render layout: !turbo_frame_request?
    end
  end
end
```

This satisfies both cases:

- **Frame navigation** (`data-turbo-frame="payment_modal"`): response includes a `<turbo-frame id="payment_modal">` that Turbo can swap into the current page.
- **Full-page navigation** (direct URL / normal link): the same view can be rendered **with layout** as a full page.

---

### 4. Turbo Streams vs Turbo Frames

This app uses **both**:

- **Turbo Frames** – for replacing a specific section of the DOM via **GET**/navigation:
  - Example: updating `"payment_modal"` when clicking “Book Appointment”.

- **Turbo Streams** – for broadcasting or responding with **actions** like `replace`, `update`, `prepend`:

  ```ruby
  render turbo_stream: [
    turbo_stream.replace("new_slot_form", partial: "slot_credits/packages", locals: { slot: @slot, calendar: @calendar })
  ]
  ```

Use frames when:

- You want “mini-page” navigations (GETs) that only change part of the page.

Use streams when:

- You’re responding to POST/PUT/DELETE (forms, button_to) or broadcasting changes and want to manipulate existing DOM elements (`replace`, `update`, `append`, etc.).

---

### 5. Checklist when adding a new Turbo Frame flow

1. **Choose a unique frame id** and wrap the target area with `turbo_frame_tag`.
2. For any `link_to` / `button_to` that should load into that frame:
   - Add `data: { turbo_frame: "your_frame_id" }`.
3. Ensure the **target action’s view**:
   - Includes `<%= turbo_frame_tag "your_frame_id" do %> … <% end %>`.
   - And the controller renders without layout for `turbo_frame_request?` when needed.
4. If you see **“Content missing”**, verify:
   - The request’s `data-turbo-frame` id.
   - The response HTML actually contains a `<turbo-frame>` with the **same id**.

---

### 6. Avoiding the “stale frame flash” when navigating back

**Symptom**

- You replace a frame via Turbo Stream (example: replacing `"new_slot_form"` with the packages UI).
- You navigate away (e.g. Home), then come back to the Schedule page.
- You briefly see the old frame content (packages) before it switches back to the normal state (slot list).

**Why it happens**

Turbo can **restore a cached snapshot** of the previous page instantly (including whatever was last inside the frame), then it fetches the new page and updates the DOM. That brief snapshot restore can look like a glitch/flash.

**Fix (page-level)**

Disable snapshot caching for that page:

```erb
<%# app/views/schedules/show.html.erb %>
<% content_for :head do %>
  <meta name="turbo-cache-control" content="no-cache">
<% end %>
```

This prevents Turbo from restoring a stale snapshot for that page, so the UI doesn’t flash an outdated frame state.

