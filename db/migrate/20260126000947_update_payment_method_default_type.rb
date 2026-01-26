class UpdatePaymentMethodDefaultType < ActiveRecord::Migration[8.0]
  def change
    change_column_default :payments, :type, from: "Payment::Razorpay", to: "PaymentMethod::Razorpay"
  end
end
