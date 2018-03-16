class RenameIndex < ActiveRecord::Migration[5.0]
  def change
    rename_column :faces, :index, :_index
  end
end
