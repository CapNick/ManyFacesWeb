class AddUrlToFaces < ActiveRecord::Migration[5.0]
  def change
    add_column :faces, :url, :string
  end
end
