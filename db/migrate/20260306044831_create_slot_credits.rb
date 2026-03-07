class CreateSlotCredits < ActiveRecord::Migration[8.0]
  def change
    create_table :slot_credits do |t|
      t.references :slot, null: false, foreign_key: true
      t.integer :slot_remaining, default: 0
      t.string :payment_order_id
      t.integer :payment_status, default: 0
      t.integer :amount, default: 0
      t.integer :package, default: 0

      t.timestamps
    end
  end
end
