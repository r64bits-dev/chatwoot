class Api::V1::Accounts::Contacts::ConversationsController < Api::V1::Accounts::Contacts::BaseController
  before_action :find_conversation, only: [:messages]
  before_action :load_messages, only: [:messages]

  PER_PAGE = 100

  def index
    @conversations = Current.account.conversations.includes(
      :assignee, :contact, :inbox, :taggings
    ).where(inbox_id: inbox_ids, contact_id: @contact.id).order(id: :desc).limit(20)
  end

  def messages; end

  def create
    # create contact if it doesn't exist
    # create conversation if it doesn't exist
    # create message
  end

  private

  def find_conversation
    search_column = Rails.env.development? ? :id : :display_id

    @conversation = Current.account.conversations.includes(:inbox)
                           .order(created_at: :desc)
                           .where(:inbox_id => inbox_ids, :contact_id => @contact.id, search_column => params[:id])
                           .first
  end

  def load_messages
    @messages = @conversation.messages.reorder(created_at: :desc).page(params[:page]).per(PER_PAGE)
    # Busca todas as conversas do contato até a data da conversa selecionada
    conversations = Current.account.conversations
                           .where(:inbox_id => inbox_ids, :contact_id => @contact.id)
                           .where('created_at <= ?', @conversation.created_at)
                           .order(created_at: :desc) 

    # Carrega mensagens de todas essas conversas
    @messages = Message.where(conversation: conversations)
                       .reorder(created_at: :desc) 
                       .page(params[:page]).per(PER_PAGE)
  end

  def inbox_ids
    if Current.user.administrator? || Current.user.agent? || Current.user.supervisor?
      Current.user.assigned_inboxes.pluck(:id)
    else
      []
    end
  end
end