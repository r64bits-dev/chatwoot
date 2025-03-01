module AutoAssignmentHandler
  extend ActiveSupport::Concern
  include Events::Types

  included do
    after_save :run_auto_assignment
  end

  private

  def run_auto_assignment
    # Round robin kicks in on conversation create & update
    # run it only when conversation status changes to open
    return unless conversation_status_changed_to_open?
    return unless should_run_auto_assignment?

    ::AutoAssignment::AgentAssignmentService.new(conversation: self, allowed_agent_ids: inbox.members_ids_with_assignment_capacity_team).perform
    conversation_participants.find_or_create_by(user_id: assignee_id) if assignee_id.present?
  end

  def should_run_auto_assignment?
    return false unless inbox.enable_auto_assignment?

    # run only if assignee is blank or doesn't have access to inbox
    assignee.blank? || inbox.members.exclude?(assignee)
  end
end
