require 'zip'

class PaymentHistory < ActiveRecord::Base

  class << self

    def import_csv(last_calculated_metric_date, uploaded_file)
      #If we are passed a zip file, extract it first
      if uploaded_file.original_filename.include?('.zip')
        csv_file = Tempfile.new(['extracted', '.csv'], 'tmp')
        Zip.on_exists_proc = true
        Zip.continue_on_exists_proc = true
        Zip::File.open(uploaded_file.path) do |zip_file|
          # Handle entries one by one
          zip_file.each do |entry|
            entry.extract(csv_file)
          end
        end
      else
        csv_file = uploaded_file
      end
      PaymentHistory.where("payment_date > ?", last_calculated_metric_date).delete_all
      options = {:key_mapping => {:payment_duration => nil, :payment_date => nil, :charge_creation_time => :payment_date, :partner_share => :revenue}}
      payments = []
      c = SmarterCSV.process(csv_file.path, options) do |csv|
        if Date.parse(csv.first[:payment_date]) > ( last_calculated_metric_date )
          csv.first[:app_title] = "Unknown" if csv.first[:app_title].blank?
          csv.first[:charge_type] =
            case csv.first[:charge_type]
            when "RecurringApplicationFee", "Recurring application fee"
               "recurring_revenue"
            when "OneTimeApplicationFee", "ThemePurchaseFee", "One time application fee", "Theme purchase fee"
              "onetime_revenue"
            when "AffiliateFee", "Affiliate fee"
              "affiliate_revenue"
            when "Manual", "ApplicationDowngradeAdjustment", "ApplicationCredit", "AffiliateFeeRefundAdjustment", "Application credit", "Application downgrade adjustment"
              "refund"
            else
              csv.first[:charge_type]
            end
          payments << PaymentHistory.new(csv.first)
        end
      end
      PaymentHistory.import payments
      csv_file.close
    end


    def calculate_metrics
      #We want metrics broken up into their respective charge types (Recurring, OneTime, Affiliate), as well as by which application. We also want calculations for every day, for chart purposes.
      charge_types = PaymentHistory.uniq.pluck(:charge_type)
      latest_calculated_metric = Metric.order("metric_date").last
      if !latest_calculated_metric.blank?
        calculate_from = latest_calculated_metric.metric_date + 1.day
      else
        calculate_from = PaymentHistory.order("payment_date").first.payment_date
        # calculate_from = 6.months.ago.to_date
      end
      calculate_to = PaymentHistory.order("payment_date").last.payment_date - 1.day #Process only full days (export day may contain partial data)
      #Loop through each date in the range
      calculate_from.upto(calculate_to) do |date|
        metrics_for_date = []
        #Then loop through each of the charge types
        charge_types.each do |charge_type|
          #Then loop through each of the app titles for this charge type to calculate those specific metrics for the day
          app_titles = PaymentHistory.where(charge_type: charge_type).uniq.pluck(:app_title)
          app_titles.each do |app_title|
            payments = PaymentHistory.where(payment_date: date, charge_type: charge_type, app_title: app_title)
            #Here's where the magic happens
            revenue = payments.sum(:revenue)
            number_of_charges = payments.count
            if number_of_charges != 0
              number_of_shops = payments.uniq.pluck(:shop).size
              average_revenue_per_shop = revenue / number_of_shops
              average_revenue_per_shop = 0.0 if average_revenue_per_shop.nan?
              average_revenue_per_charge = revenue / number_of_charges
              average_revenue_per_charge = 0.0 if average_revenue_per_charge.nan?
              churned_shops = 0
              revenue_churn = 0.0
              shop_churn = 0.0
              lifetime_value = 0.0
              repeat_customers = 0
              repeat_vs_new_customers = 0.0
              #Calculate Repeat Customers
              if charge_type == "onetime_revenue"
                payments.uniq.pluck(:shop).each do |shop|
                  previous_purchase_count = PaymentHistory.where(shop: shop, payment_date: calculate_from..date, charge_type: charge_type, app_title: app_title).count
                  repeat_customers = repeat_customers + 1 if previous_purchase_count > 1
                end
                repeat_vs_new_customers = repeat_customers.to_f / number_of_shops * 100
              end

              #Calculate Churn - Note: A shop should be charged every 30 days, however
              #in reality this is not always the case, due to Frozen charges. This means churn will
              #never be 100% accurate with only payment data to work with.
              if charge_type == "recurring_revenue" || charge_type == "affiliate_revenue"
                previous_shops = PaymentHistory.where(payment_date: date-59.days..date-30.days, charge_type: charge_type, app_title: app_title).group_by(&:shop)
                puts "Previous Shops: #{previous_shops.size}"
                if previous_shops.size != 0
                  current_shops = PaymentHistory.where(payment_date: date-29.days..date, charge_type: charge_type, app_title: app_title).group_by(&:shop)
                  churned_shops = previous_shops.reject { |h| current_shops.include? h }
                  shop_churn = churned_shops.size / previous_shops.size.to_f
                  shop_churn = 0.0 if shop_churn.nan?
                  churned_sum = 0.0
                  churned_shops.each do |shop|
                    shop[1].each do |payment|
                      churned_sum += payment.revenue
                    end
                  end
                  previous_sum = 0.0
                  previous_shops.each do |shop|
                    shop[1].each do |payment|
                      previous_sum += payment.revenue
                    end
                  end
                  revenue_churn = churned_sum / previous_sum
                  revenue_churn = 0.0 if revenue_churn.nan?
                  revenue_churn = revenue_churn * 100
                  lifetime_value = ((previous_sum / previous_shops.size) / shop_churn) if shop_churn != 0.0
                  shop_churn = shop_churn * 100
                end
              end
              puts "Revenue: #{revenue}"
              puts "Number of Charges: #{number_of_charges}"
              puts "Number of Shops: #{number_of_shops}"
              puts "Average Revenue per Shop: #{average_revenue_per_shop}"
              puts "Average Revenue per Charge: #{average_revenue_per_charge}"
              puts "Churned Shops: #{churned_shops.size}"
              puts "Revenue Churn: #{revenue_churn}"
              puts "Shop Churn: #{shop_churn}"
              puts "Lifetime Value: #{lifetime_value}"
              puts "Repeat Customers: #{repeat_customers}"
              puts "Repeat vs New: #{repeat_vs_new_customers}"

              metrics_for_date << Metric.new(
                :metric_date => date,
                :charge_type => charge_type,
                :app_title => app_title,
                :revenue => revenue,
                :number_of_charges => number_of_charges,
                :number_of_shops => number_of_shops,
                :average_revenue_per_shop => average_revenue_per_shop,
                :average_revenue_per_charge => average_revenue_per_charge,
                :revenue_churn => revenue_churn,
                :shop_churn => shop_churn,
                :lifetime_value => lifetime_value,
                :repeat_customers => repeat_customers,
                :repeat_vs_new_customers => repeat_vs_new_customers
              )
            end
          end
        end
        Metric.import metrics_for_date
      end
    end


  end
end
