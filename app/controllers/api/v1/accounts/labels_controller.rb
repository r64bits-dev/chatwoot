class Api::V1::Accounts::LabelsController < Api::V1::Accounts::BaseController
  before_action :current_account
  before_action :fetch_label, except: [:index, :create, :conversations]
  before_action :check_authorization

  def index
    @labels = policy_scope(Current.account.labels)
  end

  def show; end

  def create
    @label = Current.account.labels.create!(permitted_params)
  end

  def update
    @label.update!(permitted_params)
  end

  def destroy
    @label.destroy!
    head :ok
  end

  def conversations
    render json: conversations_labels_with_usage_count.as_json, status: :ok
  end

  private

  def fetch_label
    @label = Current.account.labels.find(params[:id])
  end

  def permitted_params
    params.require(:label).permit(:title, :description, :color, :show_on_sidebar, :team_id)
  end

  def conversations_labels_with_usage_count
    labels = Label.with_conversations_count(current_account)
    labels.map do |label|
      {
        id: label.id,
        title: label.title,
        color: label.color,
        total_used_count: label.conversations_count
      }
    end
  end
end
