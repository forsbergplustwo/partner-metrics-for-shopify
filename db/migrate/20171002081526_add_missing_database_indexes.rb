class AddMissingDatabaseIndexes < ActiveRecord::Migration
  def change
    add_index(:metrics, [:metric_date, :charge_type], :name => 'metrics_date_and_charge_type_index')
    add_index(:payment_histories, [:payment_date, :charge_type], :name => 'payment_histories_date_and_charge_type_index')
  end
end
