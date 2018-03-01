class RemoveOvrModulesFromFaces < ActiveRecord::Migration[5.0]
  def change
    remove_column :faces, :ovr_modules, :string
  end
end
