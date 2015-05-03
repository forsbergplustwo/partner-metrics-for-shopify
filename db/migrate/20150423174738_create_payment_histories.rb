class CreatePaymentHistories < ActiveRecord::Migration
  def change
    create_table :payment_histories do |t|
      t.date :payment_date, index: true
      t.text :charge_type
      t.text :app_title
      t.text :shop
      t.decimal :revenue, precision: 8, scale: 2
      t.timestamps
    end
  end
end
