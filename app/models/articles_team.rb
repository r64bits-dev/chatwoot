class ArticlesTeam < ApplicationRecord
  belongs_to :article
  belongs_to :team
end
