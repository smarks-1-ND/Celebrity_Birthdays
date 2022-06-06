class CreateCelebs < ActiveRecord::Migration[7.0]
  def change
    create_table :celebs do |t|
      t.string :nm
      t.string :name
      t.string :image
      t.text :minibio
      t.timestamps
    end
  end
end
