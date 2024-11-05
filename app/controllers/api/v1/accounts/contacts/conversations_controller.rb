class Api::V1::Accounts::Contacts::ConversationsController < Api::V1::Accounts::Contacts::BaseController
  before_action :find_conversation, only: [:messages]
  before_action :load_messages, only: [:messages]

  PER_PAGE = 20

  def index
    @conversations = Current.account.conversations.includes(
      :assignee, :contact, :inbox, :taggings
    ).where(inbox_id: inbox_ids, contact_id: @contact.id).order(id: :desc).limit(20)
  end

  def messages; end

  private

  def find_conversation
    @conversation = Current.account.conversations.includes(:inbox)
                           .where(inbox_id: inbox_ids, contact_id: @contact.id)
                           .order(created_at: :desc)
                           .find(params[:id])
  end

  def load_messages
    @messages = @conversation.messages.order(created_at: :desc).page(params[:page]).per(PER_PAGE)
  end

  def inbox_ids
    if Current.user.administrator? || Current.user.agent? || Current.user.supervisor?
      Current.user.assigned_inboxes.pluck(:id)
    else
      []
    end
  end
end
