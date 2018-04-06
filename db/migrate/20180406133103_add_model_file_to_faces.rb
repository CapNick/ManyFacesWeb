class AddModelFileToFaces < ActiveRecord::Migration[5.0]
  def change
    add_column :faces, :model, :string
  end
end
