class SuperAdmin::ReportsController < SuperAdmin::ApplicationController
  def index
    V2::ReportInvoicesBuilder.new(Account.all, params).invoices_metrics if current_user.superadmin?

    # @data = Conversation.unscoped.group_by_day(:created_at, range: 30.days.ago..2.seconds.ago).count.to_a
  end
end
