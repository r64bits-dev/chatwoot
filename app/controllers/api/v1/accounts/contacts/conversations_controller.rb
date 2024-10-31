class Api::V1::Accounts::Contacts::ConversationsController < Api::V1::Accounts::Contacts::BaseController
  before_action :load_conversations, only: [:messages]
  before_action :load_messages, only: [:messages]

  def index
    @conversations = Current.account.conversations.includes(
      :assignee, :contact, :inbox, :taggings
    ).where(inbox_id: inbox_ids, contact_id: @contact.id).order(id: :desc).limit(20)
  end

  def messages; end

  private

  def load_conversations
    @conversations = Current.account.conversations.includes(:inbox)
                            .where(inbox_id: inbox_ids, contact_id: @contact.id)
                            .order(created_at: :desc)
  end

  def load_messages
    if valid_conversation_offset?
      @current_conversation = @conversations.offset(params[:conversation_offset].to_i).first
      @messages = @current_conversation.messages.order(created_at: :desc).page(params[:page]).per(20)
    else
      @current_conversation = nil
      @messages = []
    end
  end

  def valid_conversation_offset?
    offset = params[:conversation_offset].to_i
    offset >= 0 && offset < @conversations.size
  end

  def inbox_ids
    if Current.user.administrator? || Current.user.agent? || Current.user.supervisor?
      Current.user.assigned_inboxes.pluck(:id)
    else
      []
    end
  end
end
