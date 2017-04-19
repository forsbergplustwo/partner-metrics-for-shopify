class UserMetric < ActiveRecord::Base

  USERS_TILES = [
      {"type" => "new_users", "title" => "New Users", "calculation" => "sum", "metric_type" => "any", "column" => "new_users", "display" => "number", "direction_good" => "up"},
      {"type" => "uninstall_rate", "title" => "Uninstall Rate", "calculation" => "average", "metric_type" => "any", "column" => "uninstall_rate", "display" => "percentage", "direction_good" => "down"}
  ]

  class << self
    include MetricBase
  end

end