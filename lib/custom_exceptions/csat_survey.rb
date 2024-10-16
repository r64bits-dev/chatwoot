# frozen_string_literal: true

module CustomExceptions::CsatSurvey
  class TokenError < CustomExceptions::Base
    def message
      I18n.t('errors.csat_survey.token_error')
    end
  end
end
