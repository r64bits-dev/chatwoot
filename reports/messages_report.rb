start_date = Date.new(2024, 10, 1)
end_date = Date.new(2024, 10, 31).end_of_day

global_account = Account.find_by(name: 'Global')

daily_message_counts = Message.joins(conversation: :account)
                              .where(conversations: { account_id: global_account.id })
                              .where(created_at: start_date..end_date)
                              .group('DATE(messages.created_at)', :message_type)
                              .reorder(Arel.sql('DATE(messages.created_at) ASC'))
                              .count

# Organizando o resultado
daily_message_counts_by_type = daily_message_counts.each_with_object(Hash.new do |h, k|
  h[k] = { sent: 0, received: 0 }
end) do |((date, type), count), hash|
  if type == 1 # Assumindo que 1 representa enviadas
    hash[date][:sent] = count
  else # Assumindo que 0 representa recebidas
    hash[date][:received] = count
  end
end

puts daily_message_counts_by_type
