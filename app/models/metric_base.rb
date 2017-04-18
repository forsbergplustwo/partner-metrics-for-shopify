module MetricBase
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
    change = (current.to_f / previous * 100) - 100
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