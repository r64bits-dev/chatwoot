class Api::V1::Accounts::AssignableAgentsController < Api::V1::Accounts::BaseController
  before_action :fetch_inboxes

  def index
    agent_ids = @inboxes.map do |inbox|
      authorize inbox, :show?
      member_ids = inbox.members.pluck(:user_id)
      member_ids
    end

    # Intersecção dos IDs de membros para os diferentes inboxes
    agent_ids = agent_ids.inject(:&)

    # Filtra os usuários que pertencem ao mesmo time que o usuário atual
    if current_user.administrator?
      agents = Current.account.users.where(id: agent_ids)
      agents = (agents + Current.account.administrators)
    else
      user_team_ids = current_user.teams.pluck(:id)
      agents = Current.account.users.non_administrator.joins(:teams).where(id: agent_ids, teams: { id: user_team_ids })
    end

    @assignable_agents = agents.uniq
  end

  private

  def fetch_inboxes
    @inboxes = Current.account.inboxes.find(permitted_params[:inbox_ids])
  end

  def permitted_params
    params.permit(inbox_ids: [])
  end
end
