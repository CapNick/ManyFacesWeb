class AddPhotoFileToFaces < ActiveRecord::Migration[5.0]
  def change
    add_column :faces, :photo_file, :string
  end
end
