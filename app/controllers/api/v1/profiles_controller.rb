class Api::V1::ProfilesController < Api::BaseController
  before_action :set_user
  after_action :check_if_need_to_assign_conversation, only: [:availability]

  def show; end

  def update
    params[:profile][:message_signature] = @user.name if profile_params[:message_signature].blank?

    if password_params[:password].present?
      render_could_not_create_error('Invalid current password') and return unless @user.valid_password?(password_params[:current_password])

      @user.update!(password_params.except(:current_password))
    end

    @user.update!(profile_params)
  end

  def avatar
    @user.avatar.attachment.destroy! if @user.avatar.attached?
    head :ok
  end

  def auto_offline
    @user.account_users.find_by!(account_id: auto_offline_params[:account_id]).update!(auto_offline: auto_offline_params[:auto_offline] || false)
  end

  def availability
    @user.account_users.find_by!(account_id: availability_params[:account_id]).update!(availability: availability_params[:availability])
  end

  def set_active_account
    @user.account_users.find_by(account_id: profile_params[:account_id]).update(active_at: Time.now.utc)
    head :ok
  end

  private

  def set_user
    @user = User.includes(account_users: :account).find(current_user.id)
  end

  def availability_params
    params.require(:profile).permit(:account_id, :availability)
  end

  def auto_offline_params
    params.require(:profile).permit(:account_id, :auto_offline)
  end

  def profile_params
    params.require(:profile).permit(
      :email,
      :name,
      :display_name,
      :avatar,
      :message_signature,
      :account_id,
      ui_settings: {}
    )
  end

  def password_params
    params.require(:profile).permit(
      :current_password,
      :password,
      :password_confirmation
    )
  end

  def current_account
    profile_params[:account_id].present? ? Account.find(profile_params[:account_id]) : Current.account
  end

  def check_if_need_to_assign_conversation
    Api::V1::ConversationsHelper.assign_open_conversations(current_user, current_account)
  end
end
