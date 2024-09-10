class Webhooks::InstagramController < ActionController::API
  include MetaTokenVerifyConcern

  MUTEX = Mutex.new

  def events
    Rails.logger.info('Instagram webhook received events')

    if params['object'].casecmp('instagram').zero?
      MUTEX.synchronize do
        ::Webhooks::InstagramEventsJob.perform_later(params.to_unsafe_hash[:entry])
      end
      render json: :ok
    else
      Rails.logger.warn("Message is not received from the instagram webhook event: #{params['object']}")
      head :unprocessable_entity
    end
  end

  private

  def valid_token?(token)
    token == GlobalConfigService.load('IG_VERIFY_TOKEN', '')
  end
end
