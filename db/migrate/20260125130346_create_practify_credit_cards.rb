class CreatePractifyCreditCards < ActiveRecord::Migration[8.0]
  def change
    create_table :practify_credit_cards do |t|
      t.string :last_digits
      t.integer :month
      t.integer :year
      t.string :cc_type
      t.string :name
      t.string :gateway_customer_profile_id
      t.string :gateway_payment_profile_id
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
