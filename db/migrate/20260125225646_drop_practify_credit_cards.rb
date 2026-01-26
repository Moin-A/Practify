class DropPractifyCreditCards < ActiveRecord::Migration[8.0]
  def change
    drop_table :practify_credit_cards, if_exists: true
    drop_table :practify_payment_methods, if_exists: true
  end
end
