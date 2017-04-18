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

  end

end