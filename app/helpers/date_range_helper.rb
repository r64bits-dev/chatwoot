##############################################
# Helpers to implement date range filtering to APIs
# Include in your controller or service class where params is available
##############################################

module DateRangeHelper
  def range
    since = params[:since].present? ? parse_date_time(params[:since]) : nil
    until_date = params[:until].present? ? parse_date_time(params[:until]) : nil
    return unless since && until_date

    since...until_date
  end

  def parse_date_time(datetime)
    case datetime
    when DateTime
      datetime
    when Time, Date
      datetime.to_datetime
    else
      begin
        DateTime.strptime(datetime.to_s, '%s')
      rescue StandardError
        nil
      end
    end
  end

  def months_in_range(start_date, end_date)
    start_date = start_date.to_date
    end_date = end_date.to_date

    (start_date..end_date).map { |d| Date.new(d.year, d.month, 1) }.uniq
  end

  def periods_in_range_for_group_by(group_by, start_date, end_date)
    case group_by
    when 'day'
      (start_date..end_date).to_a
    when 'year'
      (start_date.year..end_date.year).map { |year| Date.new(year, 1, 1) }
    else # 'month'
      start_month = Date.new(start_date.year, start_date.month, 1)
      end_month = Date.new(end_date.year, end_date.month, 1)
      (start_month..end_month).select { |d| d.day == 1 }
    end
  end

  def period_label_for_group_by(group_by, period_start)
    case group_by
    when 'day'
      period_start.strftime('%d %B %Y')
    when 'year'
      period_start.strftime('%Y')
    else # 'month'
      period_start.strftime('%B %Y')
    end
  end

  def period_end_for_group_by(group_by, period_start)
    case group_by
    when 'day'
      period_start.end_of_day
    when 'year'
      period_start.end_of_year
    else # 'month'
      period_start.end_of_month
    end
  end
end
