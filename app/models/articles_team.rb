# == Schema Information
#
# Table name: articles_teams
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  article_id :bigint           not null
#  team_id    :bigint           not null
#
# Indexes
#
#  index_articles_teams_on_article_id              (article_id)
#  index_articles_teams_on_article_id_and_team_id  (article_id,team_id) UNIQUE
#  index_articles_teams_on_team_id                 (team_id)
#
# Foreign Keys
#
#  fk_rails_...  (article_id => articles.id)
#  fk_rails_...  (team_id => teams.id)
#
class ArticlesTeam < ApplicationRecord
  belongs_to :article
  belongs_to :team
end
