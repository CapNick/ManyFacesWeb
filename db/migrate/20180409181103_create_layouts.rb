class CreateLayouts < ActiveRecord::Migration[5.0]
  def change
    create_table :layouts do |t|
      t.integer :width
      t.integer :height
      t.boolean :selected
    end
  end
end
