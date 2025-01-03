class Webhooks::InstagramEventsJob < MutexApplicationJob
  queue_as :default
  retry_on LockAcquisitionError, wait: 1.second, attempts: 8

  include HTTParty

  base_uri 'https://graph.facebook.com/v11.0/me'

  # @return [Array] We will support further events like reaction or seen in future
  SUPPORTED_EVENTS = [:message, :read].freeze

  def perform(entries)
    @entries = entries

    with_lock(::Redis::Alfred::IG_MESSAGE_MUTEX, sender_id: sender_id, ig_account_id: ig_account_id) do
      process_entries(entries)
    end
  end

  # @see https://developers.facebook.com/docs/messenger-platform/instagram/features/webhook
  def process_entries(entries)
    entries.each do |entry|
      entry = entry.with_indifferent_access
      messages(entry).each do |messaging|
        p "message from instagram webhook #{messaging}"
        next if message_processed?(messaging['message']['mid'])

        register_message_as_processed(messaging['message']['mid'])
        send(@event_name, messaging) if event_name(messaging)
      end
    end
  end

  private

  def ig_account_id
    @entries&.first&.dig(:id)
  end

  def sender_id
    @entries&.dig(0, :messaging, 0, :sender, :id)
  end

  def event_name(messaging)
    @event_name ||= SUPPORTED_EVENTS.find { |key| messaging.key?(key) }
  end

  def message(messaging)
    ::Instagram::MessageText.new(messaging).perform
  end

  def read(messaging)
    ::Instagram::ReadStatusService.new(params: messaging).perform
  end

  def messages(entry)
    entry[:messaging].presence || entry[:standby] || []
  end

  # Verifica se a mensagem já foi processada
  def message_processed?(message_id)
    ::Redis::Alfred.get("processed_message:#{message_id}").present?
  end

  # Registra a mensagem como processada
  def register_message_as_processed(message_id)
    ::Redis::Alfred.setex("processed_message:#{message_id}", true, 5.minutes)
  end
end
