class TeamPolicy < ApplicationPolicy
  def index?
    true
  end

  def update?
    @account_user.administrator?
  end

  def show?
    true
  end

  def create?
    @account_user.administrator?
  end

  def destroy?
    @account_user.administrator?
  end

  def conversations_unassigned?
    true
  end
end
