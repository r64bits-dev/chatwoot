#!/usr/bin/env ruby
start_date = Date.new(2024, 11, 1)
end_date = Date.new(2024, 11, 30).end_of_day

global_account = Account.find_by(name: 'Global')

daily_message_counts = Message.joins(conversation: :account)
                              .where(conversations: { account_id: global_account.id })
                              .where(created_at: start_date..end_date)
                              .group('DATE(messages.created_at)', :message_type)
                              .reorder(Arel.sql('DATE(messages.created_at) ASC'))
                              .count

# Organizando o resultado
daily_message_counts_by_type = daily_message_counts.each_with_object(Hash.new do |h, k|
  h[k] = { incoming: 0, outgoing: 0, another: 0 }
end) do |((date, type), count), hash|
  if type == 'outgoing'
    hash[date][:outgoing] = count
  elsif type == 'incoming'
    hash[date][:incoming] = count
  else
    hash[date][:another] = count
  end
end

puts daily_message_counts_by_type
