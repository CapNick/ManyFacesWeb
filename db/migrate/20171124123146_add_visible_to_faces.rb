class AddVisibleToFaces < ActiveRecord::Migration[5.0]
  def change
    add_column :faces, :visible, :boolean
  end
end
