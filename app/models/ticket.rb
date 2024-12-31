# == Schema Information
#
# Table name: tickets
#
#  id                :bigint           not null, primary key
#  assigned_to       :bigint
#  custom_attributes :jsonb
#  description       :text
#  resolved_at       :datetime
#  status            :integer          default("pending"), not null
#  title             :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  account_id        :bigint
#  conversation_id   :bigint           not null
#  user_id           :bigint           not null
#
# Indexes
#
#  index_tickets_on_account_id         (account_id)
#  index_tickets_on_assigned_to        (assigned_to)
#  index_tickets_on_conversation_id    (conversation_id)
#  index_tickets_on_custom_attributes  (custom_attributes) USING gin
#  index_tickets_on_status             (status)
#  index_tickets_on_user_id            (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (conversation_id => conversations.id)
#  fk_rails_...  (user_id => users.id)
#
class Ticket < ApplicationRecord
  belongs_to :user, inverse_of: :tickets
  belongs_to :conversation, inverse_of: :tickets
  belongs_to :assignee, class_name: 'User', foreign_key: 'assigned_to', optional: true, inverse_of: :assigned_tickets
  belongs_to :account, inverse_of: :tickets

  has_many :label_tickets, inverse_of: :ticket, dependent: :destroy
  has_many :labels, through: :label_tickets

  enum status: { pending: 0, in_progress: 1, resolved: 2 }

  validates :title, presence: true
  validates :status, inclusion: { in: statuses.keys }
  validates :custom_attributes, jsonb_attributes_length: true, allow_nil: true

  before_save :set_resolved_at

  scope :resolved, -> { where(status: :resolved) }
  scope :unresolved, -> { where(status: :pending) }
  scope :with_agents_ids, lambda { |agent_ids|
    where(assigned_to: agent_ids) if agent_ids.present?
  }

  scope :search_by_params, lambda { |search_term|
    return all if search_term.blank?

    left_joins(:assignee).where('
      tickets.description ILIKE :search OR
      users.name ILIKE :search OR
      CAST(tickets.id AS TEXT) ILIKE :search
    ', search: "%#{search_term}%")
  }
  scope :search_by_status, lambda { |status|
                             return all if status.blank?

                             where(status: status)
                           }

  scope :only_custom_attributes, ->(custom_attributes) { custom_attributes.map { |key| with_filled_custom_attribute(key) }.reduce(:or) }
  scope :with_filled_custom_attribute, lambda { |key|
    where("custom_attributes ->> ? IS NOT NULL AND custom_attributes ->> ? != ''", key.to_s, key.to_s)
  }

  scope :assigned_to, ->(user_id) { where(assigned_to: user_id).or(where(assigned_to: nil)) }

  def resolution_time
    return nil unless resolved_at

    resolved_at - created_at
  end

  def self.search(params)
    if params[:search].present?
      search_by_params(params[:search])
    elsif params[:label].present?
      joins(:labels).where(labels: { title: params[:label] })
    else
      all
    end
  end

  def custom_attribute(key)
    custom_attributes[key.to_s]
  end

  def set_custom_attribute(key, value)
    self.custom_attributes = (custom_attributes || {}).merge(key.to_s => value)
  end

  def self.to_csv
    attributes = %w[id title description status created_at]

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.find_each do |ticket|
        csv << attributes.map { |attr| ticket.send(attr) }
      end
    end
  end

  private

  def set_resolved_at
    self.resolved_at = Time.current if status_changed? && resolved?
  end
end
