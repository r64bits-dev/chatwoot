class Api::V1::Widget::InboxMembersController < Api::V1::Widget::BaseController
  skip_before_action :set_contact

  def index
    p "inbox members controller, #{@web_widget.inbox.inbox_members}"
    @inbox_members = @web_widget.inbox.inbox_members.non_administrators.includes(:user)
  rescue StandardError => e
    Rails.logger.error e
    @inbox_members = []
  end
end
