# frozen_string_literal: true

module CustomExceptions::Team
  class InvalidEmail < CustomExceptions::Base
    def message
      if @data[:disposable]
        I18n.t 'errors.signup.disposable_email'
      elsif !@data[:valid]
        I18n.t 'errors.signup.invalid_email'
      end
    end
  end

  class TeamNotFoundError < CustomExceptions::Base
    def message
      I18n.t('errors.not_found', resource: 'Team')
    end
  end

  class NeedsToBeAssignedError < CustomExceptions::Base
    def message
      I18n.t('activerecord.errors.models.team.needs_to_be_assigned')
    end
  end
end
