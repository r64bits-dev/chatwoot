class AutoAssignment::InboxRoundRobinService
  pattr_initialize [:inbox!]

  # called on inbox delete
  def clear_queue
    ::Redis::Alfred.delete(round_robin_key)
  end

  # called on inbox member create
  def add_agent_to_queue(user_id)
    ::Redis::Alfred.lpush(round_robin_key, user_id)
  end

  # called on inbox member delete
  def remove_agent_from_queue(user_id)
    ::Redis::Alfred.lrem(round_robin_key, user_id)
  end

  def reset_queue
    clear_queue
    add_agent_to_queue(inbox.inbox_members.map(&:user_id))
  end

  # end of queue management functions

  # allowed member ids = [assignable online agents supplied by the assignement service]
  # the values of allowed member ids should be in string format
  def available_agent(allowed_agent_ids: [])
    reset_queue unless validate_queue?
    user_id = get_member_from_allowed_agent_ids_hierarchical(allowed_agent_ids)
    inbox.inbox_members.find_by(user_id: user_id)&.user if user_id.present?
  end

  private

  def get_member_from_allowed_agent_ids(allowed_agent_ids)
    return nil if allowed_agent_ids.blank?

    user_id = queue.intersection(allowed_agent_ids).pop
    pop_push_to_queue(user_id)
    user_id
  end

  # Método para verificar a hierarquia de times e retornar o agente disponível
  def get_member_from_allowed_agent_ids_hierarchical(allowed_agent_ids)
    return nil if allowed_agent_ids.blank?

    current_level = 1
    while current_level <= max_hierarchy_level
      level_agent_ids = agents_by_level(current_level, allowed_agent_ids)
      user_id = level_agent_ids.intersection(queue).pop
      return pop_push_to_queue(user_id) if user_id.present?

      current_level += 1
    end
    nil
  end

  # Obtém agentes permitidos de um nível específico
  def agents_by_level(level, allowed_agent_ids)
    team_ids = Team.where(level: level).pluck(:id)
    User.joins(:team_members).where(
      team_members: { team_id: team_ids },
      id: allowed_agent_ids
    ).pluck(:id).map(&:to_s)
  end

  # Retorna o maior nível hierárquico de times
  def max_hierarchy_level
    Team.maximum(:level) || 1
  end

  def pop_push_to_queue(user_id)
    return if user_id.blank?

    remove_agent_from_queue(user_id)
    add_agent_to_queue(user_id)
  end

  def validate_queue?
    true if inbox.inbox_members.map(&:user_id).sort == queue.map(&:to_i).sort
  end

  def queue
    ::Redis::Alfred.lrange(round_robin_key)
  end

  def round_robin_key
    format(::Redis::Alfred::ROUND_ROBIN_AGENTS, inbox_id: inbox.id)
  end
end
