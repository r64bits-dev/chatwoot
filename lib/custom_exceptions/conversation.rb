# frozen_string_literal: true

module CustomExceptions::Conversation
  class NeedTeamAssignee < CustomExceptions::Base
    def message
      I18n.t('errors.conversations.need_team_assignee')
    end
  end

  class InvalidAttributes < CustomExceptions::Base
    def message
      I18n.t('errors.conversations.invalid_attributes')
    end
  end
end
