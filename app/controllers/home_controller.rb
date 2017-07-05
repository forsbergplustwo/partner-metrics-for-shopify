class HomeController < ApplicationController

  #http_basic_authenticate_with name: "metrics", password: "secret", only: [:index, :recurring, :onetime, :affiliate]

  before_action :set_params, except: [:chart_date, :import]

  def index
    @metrics = Metric.where(metric_date: @date_last..@date)
    @previous_metrics = Metric.where(metric_date: @previous_date_last..@previous_date)
    @tiles = Metric::OVERVIEW_TILES
    if !params["chart"].blank?
      @chart_tile = @tiles.select {|t| t["type"] == params["chart"] }.first
    else
      @chart_tile = @tiles.first
    end
  end

  def recurring
    @app_titles = ["All"] + Metric.where(charge_type: "recurring_revenue").uniq.pluck(:app_title)
    if params["app_title"].blank? || params["app_title"] == "All"
      m = Metric.where(charge_type: "recurring_revenue")
    else
      @app_title = params["app_title"]
      m = Metric.where(app_title: params["app_title"], charge_type: "recurring_revenue")
    end
    @metrics = m.where(metric_date: @date_last..@date)
    @previous_metrics = m.where(metric_date: @previous_date_last..@previous_date)
    @tiles = Metric::RECURRING_TILES
    if !params["chart"].blank?
      @chart_tile = @tiles.select {|t| t["type"] == params["chart"] }.first
    else
      @chart_tile = @tiles.first
    end
  end

  def onetime
    @app_titles = ["All"] + Metric.where(charge_type: "onetime_revenue").uniq.pluck(:app_title)
    if params["app_title"].blank? || params["app_title"] == "All"
      m = Metric.where(charge_type: "onetime_revenue")
    else
      @app_title = params["app_title"]
      m = Metric.where(app_title: params["app_title"], charge_type: "onetime_revenue")
    end
    @metrics = m.where(metric_date: @date_last..@date)
    @previous_metrics = m.where(metric_date: @previous_date_last..@previous_date)
    @tiles = Metric::ONETIME_TILES
    if !params["chart"].blank?
      @chart_tile = @tiles.select {|t| t["type"] == params["chart"] }.first
    else
      @chart_tile = @tiles.first
    end
  end

  def affiliate
    if params["app_title"].blank? || params["app_title"] == "All"
      m = Metric.where(charge_type: "affiliate_revenue")
    else
      @app_title = params["app_title"]
      m = Metric.where(app_title: params["app_title"], charge_type: "affiliate_revenue")
    end
    @metrics = m.where(metric_date: @date_last..@date)
    @previous_metrics = m.where(metric_date: @previous_date_last..@previous_date)
    @tiles = Metric::AFFILIATE_TILES
    if !params["chart"].blank?
      @chart_tile = @tiles.select {|t| t["type"] == params["chart"] }.first
    else
      @chart_tile = @tiles.first
    end
  end

  def chart_data
    @metrics = Metric.get_chart_data(params["date"], params["period"].to_i, params["chart_type"], params["app_title"])
    render json: @metrics
  end

  def import
    last_calculated_metric = Metric.order("metric_date").last
    last_calculated_metric_date = last_calculated_metric.blank? ? 36.months.ago.to_date : last_calculated_metric.metric_date
    filename = params[:file]
    PaymentHistory.import_csv(last_calculated_metric_date, filename)
    PaymentHistory.calculate_metrics
    flash[:notice] = "Metrics successfully updated!"
  end

  #REMOVE LATER
  def reset_metrics
    Metric.delete_all
    PaymentHistory.calculate_metrics
    flash[:notice] = "Metrics successfully reset!"
    redirect_to root_path
  end

  private

  def set_params
    @period = params["period"].blank? ? 30 : params["period"].to_i
    calculated_metrics = Metric.order("metric_date")
    if !calculated_metrics.blank?
      @first_metric_date = calculated_metrics.first.metric_date
      @latest_metric_date = calculated_metrics.last.metric_date
      @date = params["date"].blank? ? @latest_metric_date : Date.parse(params["date"])
      @date_last = @date - @period.days + 1.day
      @previous_date = @date - @period.days
      @previous_date_last = @previous_date - @period.days + 1.day
    end
  end

end
