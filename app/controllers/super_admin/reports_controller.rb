class SuperAdmin::ReportsController < SuperAdmin::ApplicationController
  def index
    return unless current_user.superadmin?

    # lest year
    params[:since] = Time.current.beginning_of_year.to_i
    params[:until] = Time.current.end_of_day.to_i
    @report_data = V2::ReportInvoicesBuilder.new(Account.all, params).invoices_metrics_admin
  end
end
