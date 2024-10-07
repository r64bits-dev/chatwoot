class EventDispatcherJob < ApplicationJob
  queue_as :critical

  def perform(event_name, timestamp, data)
    p "event name, #{event_name}, timestamp, #{timestamp}, data, #{data}"
    Rails.configuration.dispatcher.async_dispatcher.publish_event(event_name, timestamp, data)
  end
end
