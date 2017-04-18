class CreateUserMetrics < ActiveRecord::Migration
  def change
    create_table :user_metrics do |t|
      t.date :metric_date, index: true
      t.integer :number_of_installs
      t.integer :number_of_uninstalls
      t.integer :new_users
      t.timestamps
    end
  end
end
