class CreatePractifyPaymentMethods < ActiveRecord::Migration[8.0]
  def change
    create_table :practify_payment_methods do |t|
      t.string :type
      t.string :name
      t.boolean :active, default: true
      t.jsonb :preferences, default: {}

      t.timestamps
    end
  end
end
