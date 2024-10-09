class Api::V1::Accounts::TeamsController < Api::V1::Accounts::BaseController
  before_action :fetch_team, only: [:show, :update, :destroy]
  before_action :check_authorization
  before_action :find_teams, only: [:index]

  def index; end

  def show; end

  def create
    @team = Current.account.teams.new(team_params)
    @team.save!
  end

  def update
    @team.update!(team_params)
  end

  def destroy
    labels = Current.account.labels.where(team_id: [@team.id])

    labels.each { |label| label.update!({ team_id: nil }) }

    @team.destroy!
    head :ok
  end

  def conversations_unassigned
    render json: all_teams_with_unassigned_conversation_counts
  end

  private

  def fetch_team
    @team = Current.account.teams.find(params[:id])
  end

  def team_params
    params.require(:team).permit(:name, :description, :allow_auto_assign)
  end

  def find_teams
    @teams = @user.administrator? ? Current.account.teams : Current.user.teams
  end

  def all_teams_with_unassigned_conversation_counts
    all_teams = find_teams
    teams_with_counts = teams_with_conversation_counts.index_by(&:id)
    all_teams.map do |team|
      {
        id: team.id,
        team_name: team.name,
        unassigned_conversations_count: teams_with_counts&.dig(team.id, :unassigned_conversations_count) || 0
      }
    end
  end

  def teams_with_conversation_counts
    find_teams
      .left_joins(:conversations)
      .where(conversations: { assignee_id: nil, status: :open })
      .group('teams.id', 'teams.name')
      .select('teams.id, teams.name, COUNT(conversations.id) AS unassigned_conversations_count')
  end
end
