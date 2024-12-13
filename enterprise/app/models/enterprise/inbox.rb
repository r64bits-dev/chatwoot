module Enterprise::Inbox
  def member_ids_with_assignment_capacity
    max_assignment_limit = auto_assignment_config['max_assignment_limit']
    overloaded_agent_ids = max_assignment_limit.present? ? get_agent_ids_over_assignment_limit(max_assignment_limit) : []
    super - overloaded_agent_ids
  end

  def members_ids_with_assignment_capacity_team(level = nil)
    members_ids = available_members_by_team(level)
    overload_agents_ids = if max_assignment_limit_team_per_person.present?
                            get_agent_ids_over_assignment_limit(max_assignment_limit_team_per_person)
                          else
                            []
                          end

    members_ids - overload_agents_ids
  end

  def get_responses(query)
    embedding = Openai::EmbeddingsService.new.get_embedding(query)
    responses.active.nearest_neighbors(:embedding, embedding, distance: 'cosine').first(5)
  end

  def active_bot?
    super || response_bot_enabled?
  end

  def response_bot_enabled?
    account.feature_enabled?('response_bot') && response_sources.any?
  end

  private

  def get_agent_ids_over_assignment_limit(limit, ids = nil)
    query = conversations.open.select(:assignee_id).group(:assignee_id).having("count(*) >= #{limit.to_i}")
    query = query.where(assignee_id: ids) if ids.present? # Filtra pelos IDs fornecidos
    query.filter_map(&:assignee_id)
  end

  def ensure_valid_max_assignment_limit
    return if auto_assignment_config['max_assignment_limit'].blank?
    return if auto_assignment_config['max_assignment_limit'].to_i.positive?

    errors.add(:auto_assignment_config, 'max_assignment_limit must be greater than 0')
  end

  def members_group_by_teams(level)
    query = User.where(id: members.ids).joins(:teams).group('teams.level').select('teams.level, array_agg(users.id) as member_ids')
    query = query.having('teams.level = ?', level) if level.present?
    query.map { |row| { level: row.level, member_ids: row.member_ids } }
  end

  def max_assignment_limit_per_team
    auto_assignment_config['max_assignment_limit_per_team'].presence || Team.max_assignment_limit
  end

  def max_assignment_limit_team_per_person
    @max_assignment_limit_team_per_person ||=
      auto_assignment_config['max_assignment_limit_team_per_person'].presence ||
      Team.max_assignment_limit_team_per_person
  end

  def available_members_by_team(level)
    available_member_ids = []

    # Começa pelo menor nível e avança apenas se todos os membros do nível atual estiverem ocupados
    current_level = level || Team.minimum_level

    while current_level
      member_ids = members_group_by_teams(current_level).pluck(:member_ids).flatten
      break unless member_ids

      overloaded_agent_ids_team = get_agent_ids_over_assignment_limit(max_assignment_limit_per_team, member_ids)

      available_ids = member_ids - overloaded_agent_ids_team
      available_member_ids.concat(available_ids)

      break if available_member_ids.any?

      current_level = Team.where('level > ?', current_level).minimum(:level)
    end

    available_member_ids
  end
end
