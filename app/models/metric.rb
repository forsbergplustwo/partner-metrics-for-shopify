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

  MONTHS_AGO = [1,2,3,6,12]

  class << self
    include MetricBase
  end

end
