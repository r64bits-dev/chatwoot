class AddIdentifierToExistingsProducts < ActiveRecord::Migration[6.1]
  def up
    Product.where(identifier: nil).each do |product|
      product.update(identifier: product.name.downcase)
    end
  end

  def down
    Product.where.not(identifier: nil).each do |product|
      product.update(identifier: nil)
    end
  end
end
