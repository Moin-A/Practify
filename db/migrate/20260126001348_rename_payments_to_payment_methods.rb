class RenamePaymentsToPaymentMethods < ActiveRecord::Migration[8.0]
  def change
    rename_table :payments, :payment_methods
  end
end
