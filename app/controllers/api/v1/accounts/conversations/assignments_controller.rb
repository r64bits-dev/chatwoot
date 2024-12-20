class Api::V1::Accounts::Conversations::AssignmentsController < Api::V1::Accounts::Conversations::BaseController
  def create
    if params.key?(:assignee_id)
      set_agent
    elsif params.key?(:team_id)
      set_team
    else
      render json: nil
    end
  end

  private

  def set_agent
    @agent = find_and_validate_agent(params[:assignee_id])

    return raise CustomExceptions::Conversation::NeedTeamAssignee if @agent.present? && @conversation.team.blank?

    @conversation.assignee = @agent
    @conversation.assignee_id = @agent&.id
    @conversation.save!
    render_agent
  end

  def render_agent
    if @agent.nil?
      render json: nil
    else
      render partial: 'api/v1/models/agent', formats: [:json], locals: { resource: @agent }
    end
  end

  def set_team
    @team = Current.account.teams.find_by(id: params[:team_id])
    @conversation.update!(team: @team)
    render json: @team
  end

  def find_and_validate_agent(id)
    agent = Current.account.users.find_by(id: id)
    return if agent.nil?

    raise CustomExceptions::Agent::AgentOfflineError if agent.offline?

    agent
  end
end
