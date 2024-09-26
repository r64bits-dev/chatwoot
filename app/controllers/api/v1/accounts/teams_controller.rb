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
    render json: teams_with_conversation_counts.map do |team|
      { team_name: team.name, unassigned_conversations_count: team.unassigned_conversations_count || 0 }
    end
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

  def teams_with_conversation_counts
    find_teams
      .left_joins(:conversations)
      .where(conversations: { assignee_id: nil })
      .group('teams.id', 'teams.name')
      .select('teams.id, teams.name, COUNT(conversations.id) AS unassigned_conversations_count')
  end
end
