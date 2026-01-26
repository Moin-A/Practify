# Razorpay Integration Guide for Solidus

## 1. 🔐 Encryption & Security of Credit Card Data

### Current Security Measures in Solidus

**✅ Good News:** Solidus does NOT store full credit card numbers in the database!

Looking at `app/models/spree/credit_card.rb`:

```ruby
attr_reader :number, :verification_value  # These are NOT persisted!
```

**What IS stored:**
- `last_digits` - Only last 4 digits (e.g., "4338")
- `month`, `year` - Expiry date
- `name` - Cardholder name
- `cc_type` - Card brand (visa, master, etc.)
- `gateway_customer_profile_id` - Token from Razorpay (if tokenization enabled)
- `gateway_payment_profile_id` - Payment token from Razorpay

**What is NOT stored:**
- Full card number (only in memory during processing)
- CVV/CVC (never stored, only used during transaction)

### Security Best Practices for Razorpay

#### Option 1: Tokenization (RECOMMENDED) ✅
Store tokens from Razorpay instead of card data:

```ruby
# After successful payment, Razorpay returns a token
# Store this token, not the card number
credit_card.update(
  gateway_customer_profile_id: razorpay_customer_id,
  gateway_payment_profile_id: razorpay_token_id
)
```

#### Option 2: Razorpay Hosted Checkout (MOST SECURE) ✅✅
Use Razorpay's hosted checkout - card data never touches your server:

```javascript
// Frontend: Razorpay Checkout
var options = {
  "key": "YOUR_KEY",
  "amount": 50000,
  "currency": "INR",
  "handler": function (response) {
    // Send razorpay_payment_id to your backend
    // No card data sent to your server!
  }
};
var rzp = new Razorpay(options);
rzp.open();
```

#### Option 3: PCI Compliance (If storing locally)
If you MUST store card data (not recommended):
- Use encrypted columns with `attr_encrypted` gem
- Never log card numbers (already filtered in `filter_parameter_logging.rb`)
- Use HTTPS only
- Comply with PCI DSS Level 1

### Current Logging Protection

Your `config/initializers/filter_parameter_logging.rb` already filters:
```ruby
Rails.application.config.filter_parameters += [
  :passw, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn
]

# ADD THIS for credit card fields:
Rails.application.config.filter_parameters += [
  :number, :verification_value, :cvv, :cvc
]
```

---

## 2. 🔄 Ensuring Payment Gateway Params Conform to Razorpay Format

### The Transformation Layer

Your gateway class acts as the **adapter** between Solidus format and Razorpay format:

```ruby
# app/models/razorpay_gateway.rb
class RazorpayGateway
  def initialize(options = {})
    Razorpay.setup(
      options[:api_key] || options[:api_key_id],
      options[:api_secret] || options[:api_secret_key]
    )
    @options = options
  end

  # Solidus calls: purchase(money_in_cents, source, options)
  # We transform to Razorpay format
  def purchase(money, source, options = {})
    # Transform money (cents) to Razorpay format (paise for INR)
    amount = money  # Razorpay expects amount in smallest currency unit
    
    # Transform source (CreditCard) to Razorpay format
    razorpay_params = {
      amount: amount,
      currency: options[:currency] || 'INR',
      receipt: options[:order_id],  # Unique order identifier
      payment_capture: 1,  # Auto-capture (1) or authorize (0)
    }
    
    # If using card directly (not token)
    if source.respond_to?(:number) && source.number.present?
      razorpay_params[:card] = {
        number: source.number,
        name: source.name,
        expiry_month: source.month.to_s.rjust(2, '0'),
        expiry_year: source.year.to_s,
        cvv: source.verification_value
      }
    # If using token (recommended)
    elsif source.gateway_payment_profile_id.present?
      razorpay_params[:card_id] = source.gateway_payment_profile_id
    end
    
    # Add customer info
    razorpay_params[:customer] = {
      name: options[:billing_address][:name],
      email: options[:email],
      contact: options[:billing_address][:phone]
    } if options[:billing_address]
    
    # Add notes
    razorpay_params[:notes] = {
      order_id: options[:order_id],
      order_number: options[:order_id].split('-').first
    }
    
    begin
      # Call Razorpay API
      payment = Razorpay::Payment.create(razorpay_params)
      
      # Transform Razorpay response to ActiveMerchant format
      ActiveMerchant::Billing::Response.new(
        payment.status == 'captured',
        payment.status,
        payment.to_hash,
        authorization: payment.id,
        test: @options[:test] || false
      )
    rescue Razorpay::Error => e
      # Transform error to ActiveMerchant format
      ActiveMerchant::Billing::Response.new(
        false,
        e.error[:description] || 'Payment failed',
        { error: e.error },
        test: @options[:test] || false
      )
    end
  end

  def authorize(money, source, options = {})
    # Similar to purchase, but with payment_capture: 0
    razorpay_params = {
      amount: money,
      currency: options[:currency] || 'INR',
      payment_capture: 0,  # Authorize only
      # ... rest of params
    }
    
    payment = Razorpay::Payment.create(razorpay_params)
    
    ActiveMerchant::Billing::Response.new(
      payment.status == 'authorized',
      payment.status,
      payment.to_hash,
      authorization: payment.id
    )
  end

  def capture(money, authorization, options = {})
    # authorization is the payment_id from Razorpay
    payment = Razorpay::Payment.fetch(authorization)
    
    razorpay_params = {
      amount: money  # Amount in paise
    }
    
    captured_payment = payment.capture(razorpay_params)
    
    ActiveMerchant::Billing::Response.new(
      captured_payment.status == 'captured',
      captured_payment.status,
      captured_payment.to_hash,
      authorization: captured_payment.id
    )
  end

  def void(authorization, options = {})
    # Razorpay doesn't have void, use refund for authorized payments
    payment = Razorpay::Payment.fetch(authorization)
    
    if payment.status == 'authorized'
      # Refund the authorized amount
      refund = payment.refund({ amount: payment.amount })
      
      ActiveMerchant::Billing::Response.new(
        refund.status == 'processed',
        refund.status,
        refund.to_hash,
        authorization: refund.id
      )
    else
      ActiveMerchant::Billing::Response.new(
        false,
        'Cannot void captured payment',
        {}
      )
    end
  end

  def credit(money, transaction_id, options = {})
    # Refund a captured payment
    payment = Razorpay::Payment.fetch(transaction_id)
    
    refund_params = {
      amount: money,
      notes: {
        reason: 'refund',
        order_id: options[:order_id]
      }
    }
    
    refund = payment.refund(refund_params)
    
    ActiveMerchant::Billing::Response.new(
      refund.status == 'processed',
      refund.status,
      refund.to_hash,
      authorization: refund.id
    )
  end
end
```

### Parameter Mapping Reference

| Solidus Format | Razorpay Format | Notes |
|----------------|-----------------|-------|
| `money` (cents) | `amount` (paise) | Both in smallest currency unit |
| `source.number` | `card.number` | Full card number |
| `source.month` | `card.expiry_month` | "01" to "12" |
| `source.year` | `card.expiry_year` | "2025" |
| `source.verification_value` | `card.cvv` | 3-4 digits |
| `options[:currency]` | `currency` | "INR", "USD", etc. |
| `options[:order_id]` | `receipt` | Unique identifier |
| `options[:email]` | `customer.email` | Customer email |
| `options[:billing_address]` | `customer` + `notes` | Address info |

---

## 3. 🔌 How to Plug Razorpay into Your System

### Step 1: Install Razorpay Gem

```ruby
# Gemfile
gem 'razorpay'
```

```bash
bundle install
```

### Step 2: Create Payment Method Model

```ruby
# app/models/spree/payment_method/razorpay.rb
module Spree
  class PaymentMethod::Razorpay < PaymentMethod::CreditCard
    preference :api_key, :string
    preference :api_secret, :string
    preference :test_mode, :boolean, default: true
    
    def gateway_class
      RazorpayGateway
    end
    
    # Override if you want custom partial
    # def partial_name
    #   'razorpay'
    # end
  end
end
```

### Step 3: Create Gateway Class

```ruby
# app/models/razorpay_gateway.rb
require 'razorpay'

class RazorpayGateway
  def initialize(options = {})
    Razorpay.setup(
      options[:api_key] || options[:api_key_id],
      options[:api_secret] || options[:api_secret_key]
    )
    @options = options
  end

  def purchase(money, source, options = {})
    # Implementation from section 2 above
  end

  def authorize(money, source, options = {})
    # Implementation from section 2 above
  end

  def capture(money, authorization, options = {})
    # Implementation from section 2 above
  end

  def void(authorization, options = {})
    # Implementation from section 2 above
  end

  def credit(money, transaction_id, options = {})
    # Implementation from section 2 above
  end
end
```

### Step 4: Create Migration (if needed)

```ruby
# db/migrate/XXXXXX_add_razorpay_payment_method.rb
class AddRazorpayPaymentMethod < ActiveRecord::Migration[7.0]
  def up
    # Payment methods are created via admin or seeds
    # No migration needed unless adding custom columns
  end
end
```

### Step 5: Seed Payment Method (Optional)

```ruby
# db/seeds.rb or rails console
razorpay = Spree::PaymentMethod::Razorpay.find_or_initialize_by(
  name: 'Razorpay',
  type: 'Spree::PaymentMethod::Razorpay'
)

razorpay.update!(
  active: true,
  available_to_users: true,
  available_to_admin: true,
  auto_capture: true,  # Set to false if you want authorize + capture
  preferences: {
    api_key: ENV['RAZORPAY_API_KEY'],
    api_secret: ENV['RAZORPAY_API_SECRET'],
    test_mode: Rails.env.development? || Rails.env.staging?
  }
)

# Assign to stores
Spree::Store.all.each do |store|
  store.payment_methods << razorpay unless store.payment_methods.include?(razorpay)
end
```

### Step 6: Configure Environment Variables

```bash
# .env or config/application.yml
RAZORPAY_API_KEY=rzp_test_xxxxxxxxxxxxx
RAZORPAY_API_SECRET=xxxxxxxxxxxxxxxxxxxxx
```

### Step 7: Test the Integration

```ruby
# rails console
payment_method = Spree::PaymentMethod::Razorpay.first
gateway = payment_method.gateway

# Test purchase
source = Spree::CreditCard.new(
  number: '4111111111111111',
  month: 12,
  year: 2025,
  verification_value: '123',
  name: 'Test User'
)

response = gateway.purchase(
  10000,  # 100.00 INR in paise
  source,
  {
    currency: 'INR',
    order_id: 'TEST-123',
    email: 'test@example.com'
  }
)

puts response.success?  # Should be true in test mode
puts response.authorization  # Payment ID from Razorpay
```

### Step 8: (Optional) Custom Views for Razorpay Hosted Checkout

If using Razorpay's hosted checkout instead of direct card input:

```erb
<!-- app/views/checkouts/payment/_razorpay.html.erb -->
<div class="razorpay-checkout">
  <button id="razorpay-button" class="btn btn-primary">
    Pay with Razorpay
  </button>
  
  <script>
    document.getElementById('razorpay-button').onclick = function(e) {
      e.preventDefault();
      
      var options = {
        "key": "<%= payment_method.preferences[:api_key] %>",
        "amount": "<%= (@order.total * 100).to_i %>",
        "currency": "<%= @order.currency %>",
        "name": "Your Store",
        "description": "Order <%= @order.number %>",
        "order_id": "", // Create order first via API
        "handler": function (response) {
          // Submit form with razorpay_payment_id
          var form = document.createElement('form');
          form.method = 'POST';
          form.action = '<%= checkout_state_path(@order.state) %>';
          
          var input = document.createElement('input');
          input.type = 'hidden';
          input.name = 'razorpay_payment_id';
          input.value = response.razorpay_payment_id;
          form.appendChild(input);
          
          document.body.appendChild(form);
          form.submit();
        }
      };
      
      var rzp = new Razorpay(options);
      rzp.open();
    };
  </script>
</div>
```

### Step 9: Handle Webhooks (Important!)

```ruby
# app/controllers/razorpay_webhooks_controller.rb
class RazorpayWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_webhook_signature

  def create
    event = params[:event]
    payment_id = params[:payload][:payment][:entity][:id]
    
    case event
    when 'payment.captured'
      handle_payment_captured(payment_id)
    when 'payment.failed'
      handle_payment_failed(payment_id)
    when 'refund.created'
      handle_refund_created(payment_id)
    end
    
    head :ok
  end

  private

  def verify_webhook_signature
    webhook_secret = ENV['RAZORPAY_WEBHOOK_SECRET']
    signature = request.headers['X-Razorpay-Signature']
    
    expected_signature = OpenSSL::HMAC.hexdigest(
      'sha256',
      webhook_secret,
      request.raw_post
    )
    
    unless ActiveSupport::SecurityUtils.secure_compare(signature, expected_signature)
      head :unauthorized
    end
  end

  def handle_payment_captured(payment_id)
    payment = Spree::Payment.find_by(response_code: payment_id)
    payment&.complete!
  end

  def handle_payment_failed(payment_id)
    payment = Spree::Payment.find_by(response_code: payment_id)
    payment&.failure!
  end

  def handle_refund_created(payment_id)
    # Handle refund
  end
end
```

```ruby
# config/routes.rb
post '/razorpay/webhooks', to: 'razorpay_webhooks#create'
```

---

## Summary Checklist

- [x] **Security**: Credit cards not stored (only last_digits + tokens)
- [x] **Security**: Add number/CVV to filter_parameters
- [x] **Security**: Use tokenization or hosted checkout
- [x] **Format**: Gateway transforms Solidus → Razorpay format
- [x] **Integration**: PaymentMethod model created
- [x] **Integration**: Gateway class implements 5 methods
- [x] **Integration**: Payment method seeded/configured
- [x] **Integration**: Environment variables set
- [x] **Integration**: Webhooks configured
- [x] **Testing**: Test in Razorpay test mode first

---

## Additional Resources

- [Razorpay Ruby SDK](https://github.com/razorpay/razorpay-ruby)
- [Razorpay API Docs](https://razorpay.com/docs/api/)
- [PCI Compliance Guide](https://www.pcisecuritystandards.org/)
