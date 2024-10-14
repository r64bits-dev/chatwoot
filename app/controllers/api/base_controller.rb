class Api::BaseController < ApplicationController
  include AccessTokenAuthHelper
  respond_to :json
  before_action :authenticate_access_token!, if: :authenticate_by_access_token?
  before_action :validate_bot_access_token!, if: :authenticate_by_access_token?
  before_action :authenticate_user!, unless: :authenticate_by_access_token?

  rescue_from CustomExceptions::Account::InvalidEmail,
              CustomExceptions::Account::UserExists,
              CustomExceptions::Account::UserErrors,
              CustomExceptions::Team::InvalidEmail,
              CustomExceptions::Team::TeamNotFoundError,
              CustomExceptions::Agent::InvalidEmail,
              CustomExceptions::Agent::AgentOfflineError,
              CustomExceptions::Agent::AgentNotFoundError,
              CustomExceptions::Agent::UserExists,
              CustomExceptions::Agent::UserErrors,
              CustomExceptions::Conversation::NeedTeamAssignee,
              with: :render_error_response

  def render_error_response(exception = nil)
    render json: { error: exception&.message || exception.to_s }, status: :unprocessable_entity
  end

  private

  def authenticate_by_access_token?
    request.headers[:api_access_token].present? || request.headers[:HTTP_API_ACCESS_TOKEN].present?
  end

  def check_authorization(model = nil)
    model ||= controller_name.classify.constantize

    authorize(model)
  end

  def check_admin_authorization?
    raise Pundit::NotAuthorizedError unless Current.account_user.administrator?
  end
end
