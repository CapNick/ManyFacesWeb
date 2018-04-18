class RenamePhotoFileToModel < ActiveRecord::Migration[5.0]
  def change
    remove_column :faces, :model, :string
    rename_column :faces, :photo_file, :model_file
  end
end
