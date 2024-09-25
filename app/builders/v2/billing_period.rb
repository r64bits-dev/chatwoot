class V2::BillingPeriod
  attr_reader :group_by, :start_time, :end_time, :period_start, :period_end

  def initialize(group_by, period_start, period_end = nil)
    @group_by = group_by
    @start_time = period_start
    @end_time = period_end || period_start

    set_period_boundaries
  end

  private

  def set_period_boundaries
    case group_by
    when 'days'
      @period_start = start_time.beginning_of_day
      @period_end = end_time.end_of_day
    when 'month'
      @period_start = start_time.beginning_of_month
      @period_end = end_time.end_of_month
    when 'year'
      @period_start = start_time.beginning_of_year
      @period_end = end_time.end_of_year
    else
      raise ArgumentError, "Invalid group_by value: #{group_by}. Expected 'days', 'month', or 'year'."
    end
  end
end
