class CreateMetrics < ActiveRecord::Migration
  def change
    create_table :metrics do |t|
      t.date :metric_date, index: true
      t.text :charge_type
      t.text :app_title
      t.decimal :revenue, precision: 10, scale: 2
      t.integer :number_of_charges
      t.integer :number_of_shops
      t.integer :repeat_customers
      t.decimal :repeat_vs_new_customers, precision: 10, scale: 2
      t.decimal :average_revenue_per_shop, precision: 10, scale: 2
      t.decimal :average_revenue_per_charge, precision: 10, scale: 2
      t.decimal :shop_churn, precision: 10, scale: 2
      t.decimal :revenue_churn, precision: 10, scale: 2
      t.decimal :lifetime_value, precision: 10, scale: 2
      t.timestamps
    end
  end
end
