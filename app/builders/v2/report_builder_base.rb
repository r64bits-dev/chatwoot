class V2::ReportBuilderBase
  include DateRangeHelper

  attr_reader :accounts, :params, :group_by, :date_range

  DEFAULT_GROUP_BY = 'month'.freeze
  DEFAULT_MONTHS_BEFORE = 3

  def initialize(accounts, params)
    @accounts = Array(accounts)
    @params = params
    @group_by = params[:group_by] || DEFAULT_GROUP_BY
    @date_range = range
    @total = 0
  end

  def calculate_date_range
    start_date = date_range&.first&.to_date || default_start_date
    end_date = date_range&.last&.to_date || default_end_date
    [start_date, end_date]
  end

  protected

  def adjust_end_date(end_date)
    end_date.day == 1 ? (end_date - 1.day).end_of_month : end_date.end_of_month
  end

  def default_start_date
    accounts.minimum(:created_at).beginning_of_day
  end

  def default_end_date
    Time.current.end_of_month
  end
end
