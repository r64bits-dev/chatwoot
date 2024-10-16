class Public::Api::V1::CsatSurveyController < PublicController
  before_action :set_conversation
  before_action :set_message, except: [:create]

  def show; end

  def create
    ActiveRecord::Base.transaction do
      message = @conversation.messages.create!(
        {
          message_type: 'incoming',
          content_type: 'input_csat',
          content_attributes: {
            csat_survey_response: {
              rating: params[:message][:rating],
              feedback_message: params[:message][:content]
            }
          },
          account_id: @conversation.account_id,
          inbox_id: @conversation.inbox_id
        }
      )

      CsatSurveyResponse.create!(
        feedback_message: params[:message][:content],
        rating: params[:message][:rating],
        account_id: @conversation.account_id,
        contact_id: @conversation.contact_id,
        conversation_id: @conversation.id,
        message_id: message.id,
        assigned_agent_id: @conversation.assignee_id # Associa o agente responsável pela conversa
      )
    end

    render json: { message: 'CSAT survey and response created successfully' }, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def update
    if check_csat_locked
      render json: { error: 'Você não pode atualizar a pesquisa CSAT após 14 dias' }, status: :unprocessable_entity
      return
    end

    @message.update!(message_update_params[:message])
  end

  private

  def set_conversation
    return if params[:id].blank?

    @conversation = Conversation.find_by!(uuid: params[:id])
  end

  def set_message
    @message = @conversation.messages
                            .where(content_type: 'input_csat')
                            .last
  end

  def message_update_params
    params.permit(message: [{ submitted_values: [:name, :title, :value, { csat_survey_response: [:feedback_message, :rating] }] }])
  end

  def check_csat_locked
    (Time.zone.now.to_date - @message.created_at.to_date).to_i > 14
  end
end
