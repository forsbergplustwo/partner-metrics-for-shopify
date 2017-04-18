class UserMetric < ActiveRecord::Base

  USERS_TILES = [
      {"type" => "new_users", "title" => "New Users", "calculation" => "sum", "metric_type" => "any", "column" => "new_users", "display" => "number", "direction_good" => "up"}
  ]

  class << self
    include MetricBase
  end

end