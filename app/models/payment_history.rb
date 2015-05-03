class PaymentHistory < ActiveRecord::Base

  class << self

    def import_csv(last_calculated_metric_date, filename)
      PaymentHistory.where("payment_date > ?", last_calculated_metric_date).delete_all
      options = {:key_mapping => {:payment_duration => nil, :payment_date => nil, :charge_creation_time => :payment_date, :partner_share => :revenue}}
      c = SmarterCSV.process(filename, options) do |csv|
        if Date.parse(csv.first[:payment_date]) > ( last_calculated_metric_date )
          csv.first[:app_title] = "FORSBERGtwo" if csv.first[:app_title].blank?
          csv.first[:charge_type] = "recurring_revenue" if csv.first[:charge_type] == "RecurringApplicationFee"
          csv.first[:charge_type] = "onetime_revenue" if csv.first[:charge_type] == "OneTimeApplicationFee"
          csv.first[:charge_type] = "onetime_revenue" if csv.first[:charge_type] == "ThemePurchaseFee"
          csv.first[:charge_type] = "affiliate_revenue" if csv.first[:charge_type] == "AffiliateFee"
          csv.first[:charge_type] = "refund" if csv.first[:charge_type] == "Manual"
          PaymentHistory.create(csv.first)
        end
      end
    end


    def calculate_metrics
      #We want metrics broken up into their respective charge types (Recurring, OneTime, Affiliate), as well as by which application. We also want calculations for every day, for chart purposes.
      charge_types = PaymentHistory.uniq.pluck(:charge_type)
      latest_calculated_metric = Metric.order("metric_date").last
      if !latest_calculated_metric.blank?
        calculate_from = latest_calculated_metric.metric_date + 1.day
      else
        calculate_from = PaymentHistory.order("payment_date").first.payment_date
        #calculate_from = 6.months.ago.to_date
      end
      calculate_to = PaymentHistory.order("payment_date").last.payment_date - 1.day #Process only full days (export day may contain partial data)
      #Loop through each date in the range
      calculate_from.upto(calculate_to) do |date|
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

              #Calculate Churn - Not very reliable
              if charge_type == "recurring_revenue" || charge_type == "affiliate_revenue"
                #previous_date = date - 33.days # Can't do just - 30 because sometimes they are charged not exactly 30 days later, might be slightly before or after.
                #safety_buffer = 7.days #Needed because Shopify will roll some to next date. So we check for if they payed after 29, 30 or 31 days
                previous_shops = PaymentHistory.where(payment_date: date-59.days..date-30.days, charge_type: charge_type, app_title: app_title).group_by(&:shop)
                puts "Previous Shops: #{previous_shops.size}"
                if previous_shops.size != 0
                  current_shops = PaymentHistory.where(payment_date: date-29..date, charge_type: charge_type, app_title: app_title).group_by(&:shop)
                  churned_shops = previous_shops.reject { |h| current_shops.include? h }
                  shop_churn = churned_shops.size / previous_shops.size.to_f
                  lifetime_value = average_revenue_per_shop / shop_churn if shop_churn != 0.0
                  shop_churn = shop_churn * 100
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
                  revenue_churn = revenue_churn * 100
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

              Metric.create(
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
      end
    end


  end
end
