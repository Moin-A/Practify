class CreatePaymentRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :appointment, null: false, foreign_key: true
      t.references :payment_method, null: false, foreign_key: { to_table: :payment_methods }
      t.integer :amount, null: false
      t.string :currency, default: "INR"
      t.string :status, default: "pending"

      t.timestamps
    end

    add_index :payments, :status
  end
end
