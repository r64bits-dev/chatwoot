class RoomChannel < ApplicationCable::Channel
  def subscribed
    # TODO: should we only do ensure stream  if current account is present?
    # for now going ahead with guard clauses in update_subscription and broadcast_presence

    ensure_stream
    current_user
    current_account
    update_subscription
    broadcast_presence
  end

  def update_presence
    update_subscription
    broadcast_presence
  end

  private

  # RoomChannel
  def broadcast_presence
    return if @current_account.blank?

    data = {}
    # Extrai os dados serializáveis dos usuários disponíveis
    if @current_user.is_a? AccountUser
      p 'find available users by type account user'
      available_users = ::OnlineStatusTracker.get_available_users(@current_account.id).map do |user|
        { user_id: user[:user_id], availability: user[:availability] }
      end
      data = { account_id: @current_account.id, users: available_users }
    elsif @current_user.is_a? User
      p 'find available users by type user'
      data = { account_id: @current_account.id, users: ::OnlineStatusTracker.get_available_users(@current_account.id) }
    end
    ActionCable.server.broadcast(@pubsub_token, { event: 'presence.update', data: data })
  rescue StandardError => e
    Rails.logger.error "Presence broadcast error: #{e.message} #{e.backtrace}"
  end

  def ensure_stream
    @pubsub_token = params[:pubsub_token]
    stream_from @pubsub_token
  end

  def update_subscription
    return if @current_account.blank?

    p "current class name: #{@current_user.class.name}, current id: #{@current_user.id}"

    ::OnlineStatusTracker.update_presence(@current_account.id, @current_user.class.name, @current_user.id)
  rescue StandardError => e
    Rails.logger.error "Online status tracker error: #{e.message} #{e.backtrace}"
  end

  def current_user
    @current_user ||= if params[:user_id].blank?
                        ContactInbox.find_by!(pubsub_token: @pubsub_token).contact
                      else
                        User.find_by!(pubsub_token: @pubsub_token, id: params[:user_id])
                      end
  end

  def current_account
    return if current_user.blank?

    @current_account ||= if @current_user.is_a? Contact
                           @current_user.account
                         else
                           @current_user.accounts.find(params[:account_id])
                         end
  end
end
