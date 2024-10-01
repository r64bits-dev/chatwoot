class SuperAdmin::ReportsController < SuperAdmin::ApplicationController
  def index
    return unless current_user.superadmin?

    @report_data = V2::ReportInvoicesBuilder.new(Account.all, params).invoices_metrics
  end
end
