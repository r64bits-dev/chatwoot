# == Schema Information
#
# Table name: labels
#
#  id              :bigint           not null, primary key
#  color           :string           default("#1f93ff"), not null
#  description     :text
#  show_on_sidebar :boolean
#  title           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  account_id      :bigint
#  team_id         :bigint
#
# Indexes
#
#  index_labels_on_account_id            (account_id)
#  index_labels_on_team_id               (team_id)
#  index_labels_on_title_and_account_id  (title,account_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (team_id => teams.id)
#
class Label < ApplicationRecord
  include RegexHelper
  include AccountCacheRevalidator

  belongs_to :account

  validates :title,
            presence: { message: I18n.t('errors.validations.presence') },
            format: { with: UNICODE_CHARACTER_NUMBER_HYPHEN_UNDERSCORE },
            uniqueness: { scope: :account_id }

  has_many :label_tickets, inverse_of: :label, dependent: :destroy
  has_many :tickets, through: :label_tickets

  after_update_commit :update_associated_models
  default_scope { order(:title) }

  scope :find_id_or_title, lambda { |id_or_title|
    if id_or_title.is_a?(Integer)
      find(id_or_title)
    else
      find_title(id_or_title)
    end
  }
  scope :find_title, ->(title) { where(title: title.downcase.strip) }
  scope :with_usage_count, lambda { |association|
    left_joins(association)
      .select("labels.*, COUNT(#{association}.id) AS usage_count")
      .group('labels.id')
      .order('usage_count DESC')
  }

  before_validation do
    self.title = title.downcase if attribute_present?('title')
  end

  def self.with_conversations_count(account)
    counts = account.conversations.tag_counts_on(:labels)

    label_counts = counts.each_with_object({}) do |tag, hash|
      hash[tag.name] = tag.taggings_count
    end

    where(account_id: account.id).map do |label|
      count = label_counts[label.title] || 0
      label.define_singleton_method(:conversations_count) { count }
      label
    end
  end

  def conversations
    account.conversations.tagged_with(title)
  end

  def messages
    account.messages.where(conversation_id: conversations.pluck(:id))
  end

  def reporting_events
    account.reporting_events.where(conversation_id: conversations.pluck(:id))
  end

  private

  def update_associated_models
    return unless title_previously_changed?

    Labels::UpdateJob.perform_later(title, title_previously_was, account_id)
  end
end
