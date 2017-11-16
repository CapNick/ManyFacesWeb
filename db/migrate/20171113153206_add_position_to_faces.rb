class AddPositionToFaces < ActiveRecord::Migration[5.0]
  def change
    add_column :faces, :telephone, :string
    add_column :faces, :position, :string
    add_column :faces, :type, :string
  end
end
