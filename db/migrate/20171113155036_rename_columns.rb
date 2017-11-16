class RenameColumns < ActiveRecord::Migration[5.0]
  def change
    rename_column :faces, :type, :_type
    rename_column :faces, :telephone, :phone
  end
end
