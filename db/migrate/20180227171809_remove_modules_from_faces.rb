class RemoveModulesFromFaces < ActiveRecord::Migration[5.0]
  def change
    remove_column :faces, :modules, :string
  end
end
