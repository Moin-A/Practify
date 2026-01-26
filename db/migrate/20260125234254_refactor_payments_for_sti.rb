class RefactorPaymentsForSti < ActiveRecord::Migration[8.0]
  def change
    # Add type column for STI
    add_column :payments, :type, :string, default: "Payment::Razorpay"
    add_index :payments, :type

    # Add generic gateway columns (for common interface)
    add_column :payments, :gateway_transaction_id, :string
    add_column :payments, :gateway_order_id, :string
    add_column :payments, :gateway_data, :jsonb, default: {}

    # Migrate existing data to new columns
    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE payments 
          SET gateway_transaction_id = razorpay_payment_id,
              gateway_order_id = razorpay_order_id,
              gateway_data = jsonb_build_object('signature', razorpay_signature)
          WHERE razorpay_payment_id IS NOT NULL
        SQL
      end
    end

    # Add index for lookups
    add_index :payments, :gateway_transaction_id
    add_index :payments, :gateway_order_id
  end
end
