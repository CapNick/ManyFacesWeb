class AddOverrides < ActiveRecord::Migration[5.0]
  def change
    add_column :faces, :ovr_name, :string
    add_column :faces, :ovr_type, :string
    add_column :faces, :ovr_position, :string
    add_column :faces, :ovr_modules, :string
    add_column :faces, :ovr_room, :string
    add_column :faces, :ovr_email, :string
    add_column :faces, :ovr_phone, :string
    add_column :faces, :ovr_photo, :string
  end
end
