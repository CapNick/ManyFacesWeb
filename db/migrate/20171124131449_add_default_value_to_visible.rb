class AddDefaultValueToVisible < ActiveRecord::Migration[5.0]
  def change
    change_column :faces, :visible, :boolean, default: true
  end
end
