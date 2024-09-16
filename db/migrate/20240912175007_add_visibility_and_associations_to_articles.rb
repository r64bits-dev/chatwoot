class AddVisibilityAndAssociationsToArticles < ActiveRecord::Migration[7.0]
  def change
    # Adiciona a coluna 'visibility' na tabela 'articles'
    add_column :articles, :visibility, :integer, default: 0, null: false

    # Cria a tabela de associação 'articles_teams' para relacionar artigos com equipes
    create_table :articles_teams do |t|
      t.references :article, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true

      t.timestamps
    end

    # Adiciona um índice único para garantir que não haja duplicatas
    add_index :articles_teams, [:article_id, :team_id], unique: true
  end
end
