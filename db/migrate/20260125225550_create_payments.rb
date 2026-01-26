class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :user, null: false, foreign_key: true
      t.string :razorpay_payment_id
      t.string :razorpay_order_id
      t.integer :amount
      t.string :currency
      t.string :status

      t.timestamps
    end
  end
end
