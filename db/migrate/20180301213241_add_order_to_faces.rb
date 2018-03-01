class AddOrderToFaces < ActiveRecord::Migration[5.0]
  def change
    add_column :faces, :order, :integer
  end
end
