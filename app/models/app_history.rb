class AppHistory < ActiveRecord::Base

  class << self

    def import_csv(filename)
      last_imported_record_date = AppHistory.maximum(:date)

      app_histories = []
      c = SmarterCSV.process(filename) do |csv|
        unless last_imported_record_date != nil && Date.parse(csv.first[:date]) <= ( last_imported_record_date )
          app_histories << AppHistory.new(csv.first)
        end
      end
      AppHistory.import app_histories
    end

    def calculate_metrics
      # following convention here (from payment_history), but could be 1,000,000,000 times faster using SQL like...
      #    select date, count(*) from AppHistory where event = 'ApplicationInstalledEvent' group by date

      calculate_from = UserMetric.maximum(:metric_date)
      if calculate_from == nil
        calculate_from = AppHistory.minimum(:date)
      end
      calculate_to = AppHistory.maximum(:date) - 1.day #Process only full days (export day may contain partial data)
      #Loop through each date in the range
      calculate_from.upto(calculate_to) do |date|
        metrics_for_date = []

        number_of_installs = AppHistory.where(date: date, event: 'ApplicationInstalledEvent').count
        number_of_uninstalls = AppHistory.where(date: date, event: 'ApplicationUninstalledEvent').count

        metrics_for_date << UserMetric.new(
            :metric_date => date,
            :number_of_installs => number_of_installs,
            :number_of_uninstalls => number_of_uninstalls,
            :new_users => number_of_installs - number_of_uninstalls
        )

        UserMetric.import metrics_for_date
      end
    end

  end

end