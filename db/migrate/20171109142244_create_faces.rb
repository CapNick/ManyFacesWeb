class CreateFaces < ActiveRecord::Migration[5.0]
  def change
    create_table :faces do |t|
      t.string :name
      t.string :room
      t.string :modules
      t.string :email
    end
  end
end
