class AddShopCountryToPayments < ActiveRecord::Migration
  def change
    add_column :payment_histories, :shop_country, :string
  end
end
