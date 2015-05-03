class Metric < ActiveRecord::Base

  OVERVIEW_TILES = [
    {"type" => "total_revenue", "title" => "Total Revenue", "calculation" => "sum", "metric_type" => "any", "column" => "revenue", "display" => "currency", "direction_good" => "up"},
    {"type" => "recurring_revenue", "title" => "Recurring Revenue", "calculation" => "sum", "metric_type" => "recurring_revenue", "column" => "revenue", "display" => "currency", "direction_good" => "up"},
    {"type" => "onetime_revenue", "title" => "One-Time Revenue", "calculation" => "sum", "metric_type" => "onetime_revenue", "column" => "revenue", "display" => "currency", "direction_good" => "up"},
    {"type" => "affiliate_revenue", "title" => "Affiliate Revenue", "calculation" => "sum", "metric_type" => "affiliate_revenue", "column" => "revenue", "display" => "currency", "direction_good" => "up"},
    {"type" => "refund", "column" => "revenue", "title" => "Refunds", "calculation" => "sum", "metric_type" => "refund", "display" => "currency", "direction_good" => "up"},
    {"type" => "avg_revenue_per_shop", "title" => "Avg. Revenue per User", "calculation" => "average", "metric_type" => "any", "column" => "average_revenue_per_shop", "display" => "currency", "direction_good" => "up"}
  ]

  RECURRING_TILES = [
    {"type" => "recurring_revenue", "title" => "Revenue", "calculation" => "sum", "metric_type" => "recurring_revenue", "column" => "revenue", "display" => "currency", "direction_good" => "up"},
    {"type" => "number_of_shops", "title" => "Paying Users", "calculation" => "sum", "metric_type" => "recurring_revenue", "column" => "number_of_shops", "display" => "number", "direction_good" => "up"},
    {"type" => "recurring_avg_revenue_per_shop", "title" => "Avg. Revenue per User", "calculation" => "average", "metric_type" => "recurring_revenue", "column" => "average_revenue_per_shop", "display" => "currency", "direction_good" => "up"},
    {"type" => "shop_churn", "title" => "User Churn (30 Day Lag)", "calculation" => "average", "metric_type" => "recurring_revenue", "column" => "shop_churn", "display" => "percentage", "direction_good" => "down"},
    {"type" => "revenue_churn", "title" => "Revenue Churn (30 Day Lag)", "calculation" => "average", "metric_type" => "recurring_revenue", "column" => "revenue_churn", "display" => "percentage", "direction_good" => "down"},
    {"type" => "lifetime_value", "title" => "Lifetime Value (30 Day Lag)", "calculation" => "average", "metric_type" => "recurring_revenue", "column" => "lifetime_value", "display" => "currency", "direction_good" => "up"}
  ]

  ONETIME_TILES = [
    {"type" => "onetime_revenue", "title" => "Revenue", "calculation" => "sum", "metric_type" => "onetime_revenue", "column" => "revenue", "display" => "currency", "direction_good" => "up"},
    {"type" => "onetime_avg_revenue_per_charge", "title" => "Avg. Revenue per Sale", "calculation" => "average", "metric_type" => "onetime_revenue", "column" => "average_revenue_per_charge", "display" => "currency", "direction_good" => "up"},
    {"type" => "onetime_avg_revenue_per_shop", "title" => "Avg. Revenue per User", "calculation" => "average", "metric_type" => "onetime_revenue", "column" => "average_revenue_per_shop", "display" => "currency", "direction_good" => "up"},
    {"type" => "onetime_number_of_charges", "title" => "Number of Sales", "calculation" => "sum", "metric_type" => "onetime_revenue", "column" => "number_of_charges", "display" => "number", "direction_good" => "up"},
    {"type" => "repeat_customers", "title" => "Repeat Customers", "calculation" => "sum", "metric_type" => "onetime_revenue", "column" => "repeat_customers", "display" => "number", "direction_good" => "up"},
    {"type" => "repeat_vs_new_customers", "title" => "Repeat vs New Customers", "calculation" => "average", "metric_type" => "onetime_revenue", "column" => "repeat_vs_new_customers", "display" => "percentage", "direction_good" => "up"},
  ]

  AFFILIATE_TILES = [
    {"type" => "affiliate_revenue", "title" => "Revenue", "calculation" => "sum", "metric_type" => "affiliate_revenue", "column" => "revenue", "display" => "currency", "direction_good" => "up"},
    {"type" => "affiliate_number_of_charges", "title" => "Number of Affiliates", "calculation" => "sum", "metric_type" => "affiliate_revenue", "column" => "number_of_charges", "display" => "number", "direction_good" => "up"},
    {"type" => "affiliate_avg_revenue_per_shop", "title" => "Avg. Revenue per User", "calculation" => "average", "metric_type" => "affiliate_revenue", "column" => "average_revenue_per_shop", "display" => "currency", "direction_good" => "up"}
  ]

  MONTHS_AGO = [1,3,6,12]





  class << self


    def calculate_value(type)
      if type["metric_type"] == "any"
        value = self.all
      else
        value = self.where(charge_type: type["metric_type"])
      end
      if type["calculation"] == "sum"
        value = value.sum(type["column"])
      else
        value = value.average(type["column"])
      end
      value
    end



    def calculate_change(type, previous_metrics)
      if type["metric_type"] == "any"
        current = self.all
        previous = previous_metrics
      else
        current = self.where(charge_type: type["metric_type"])
        previous = previous_metrics.where(charge_type: type["metric_type"])
      end
      if type["calculation"] == "sum"
        current = current.sum(type["column"])
        previous = previous.sum(type["column"])
      else
        current = current.average(type["column"])
        previous = previous.average(type["column"])
      end
      change = (current.to_f - previous) / current * 100
      change
    end



    def get_chart_data(date, period, type, app_title)
      date = Date.parse(date)
      if app_title.blank?
        metrics = self.all
      else
        metrics = self.where(app_title: app_title)
      end
      if type["metric_type"] == "any"
        first_date = metrics.order("metric_date").first.metric_date
        group_options = group_options(date, first_date, period)
        metrics = metrics.group(group_options, {restrict: true})
      else
        first_date = metrics.where(charge_type: type["metric_type"]).order("metric_date").first.metric_date
        group_options = group_options(date, first_date, period)
        metrics = metrics.where(charge_type: type["metric_type"]).group(group_options, restrict: true)
      end
      if type["calculation"] == "sum"
        metrics = metrics.sum(type["column"])
      else
        metrics = metrics.average(type["column"])
      end
      group_options[:metric_date].each do |g|
        gf = g.first.to_date
        metrics[gf.to_s] = 0 if metrics[gf.to_s].blank?
      end
      metrics.sort_by{ |h| h[0].to_datetime }
      metrics
    end



    def group_options(date, first_date, period)
      counter_date = date
      group_options = {metric_date: {}}
      until counter_date < first_date do
        group_options[:metric_date][counter_date] = counter_date.beginning_of_day - period.days + 1.day..counter_date.end_of_day
        counter_date = counter_date - period.days
      end
      group_options
    end



    def calculate_value_period_ago(month_ago, date, period, type, app_title)
      date = date - (period * month_ago).days
      last_date = date - period.days + 1.day
      if app_title.blank?
        value = self.where(metric_date: last_date..date)
      else
        value = self.where(metric_date: last_date..date, app_title: app_title)
      end
      if type["metric_type"] != "any"
        value = value.where(charge_type: type["metric_type"])
      end
      if type["calculation"] == "sum"
        value = value.sum(type["column"])
      else
        value = value.average(type["column"])
      end
    end



  end

end
