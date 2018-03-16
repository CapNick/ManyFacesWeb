class RenameOrderToIndex < ActiveRecord::Migration[5.0]
  def change
    rename_column :faces, :order, :_
  end
end
