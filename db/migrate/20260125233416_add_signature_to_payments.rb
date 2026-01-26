class AddSignatureToPayments < ActiveRecord::Migration[8.0]
  def change
    add_column :payments, :razorpay_signature, :string
  end
end
