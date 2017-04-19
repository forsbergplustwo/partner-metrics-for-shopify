class AddUninstallRateToUserMetrics < ActiveRecord::Migration
  def change
    add_column :user_metrics, :uninstall_rate, :decimal, precision: 10, scale: 2
  end
end
