class AddLabelToFaces < ActiveRecord::Migration[5.0]
  def change
    add_column :faces, :label, :string
  end
end
