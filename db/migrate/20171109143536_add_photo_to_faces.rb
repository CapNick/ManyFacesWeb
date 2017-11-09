class AddPhotoToFaces < ActiveRecord::Migration[5.0]
  def change
    add_column :faces, :photo, :string
    add_column :faces, :created_at, :datetime
    add_column :faces, :updated_at, :datetime
  end
end
