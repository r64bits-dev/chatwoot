# == Schema Information
#
# Table name: products
#
#  id           :bigint           not null, primary key
#  description  :text
#  details      :jsonb
#  identifier   :string
#  name         :string           not null
#  price        :decimal(10, 2)   not null
#  product_type :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_products_on_identifier    (identifier) UNIQUE
#  index_products_on_product_type  (product_type)
#
class Product < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :account_products, dependent: :destroy
  has_many :accounts, through: :account_products

  enum product_type: { plan: 'Plano', other: 'Other' }

  validates :product_type, presence: true, inclusion: { in: product_types.keys }
  validates :identifier, presence: true, uniqueness: true

  MINIMUM_PRICE = 199.0
  MAXIMUM_CONVERSATIONS = 600
  MAXIMUM_AGENTS = 2
end
