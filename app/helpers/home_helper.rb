module HomeHelper

  def nav_link(link_text, link_path)
    class_name = current_page?(link_path) ? 'active' : ''

    content_tag(:li, :class => class_name) do
      link_to link_text, link_path
    end
  end

  def number_to_currency_with_precision(value)
    precision = value < 100 ? 2 : 0
    number = number_to_currency(value, precision: precision)
  end

  def number_to_percentage_with_precision(value)
    precision = value < 10 ? 2 : 1
    percentage = number_to_percentage(value, precision: precision)
    value > 0 ? '+' + percentage : percentage
  end

  def metric_change_color(metric_change, direction_good)
   if direction_good == "up"
     return metric_change > 0.01 ? 'text-success' : metric_change < -0.01 ? 'text-danger' : ''
   else
     return metric_change < -0.01 ? 'text-success' : metric_change > 0.01 ? 'text-danger' : ''
   end
  end

  def show_averages(period, type)
    if type["calculation"] == "average" || type["type"] == "lifetime_value" || type["type"] == "repeat_customers"
      return false
    elsif period != 30
      return false
    else
      return true
    end
  end

  def periods_ago(period)
    if period == 30
      return [1, 2, 3, 6, 12]
    elsif period == 7
      return [1, 2, 4, 8,12]
    else
      return [1, 7, 14, 30,60]
    end
  end

  def period_word(period)
    if period == 30
      return "Month"
    elsif period == 7
      return "Week"
    else
      return "Day"
    end
  end

end
