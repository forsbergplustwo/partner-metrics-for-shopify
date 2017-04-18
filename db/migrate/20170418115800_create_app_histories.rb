class CreateAppHistories < ActiveRecord::Migration
  def change
    create_table :app_histories do |t|
      t.date :date, index: true
      t.text :event
      t.text :details
      t.date :billing_on
      t.text :shop_name
      t.text :shop_country
      t.text :shop_email
      t.text :shop_domain
      t.timestamps
    end
  end
end
