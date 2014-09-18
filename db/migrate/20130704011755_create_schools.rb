class CreateSchools < ActiveRecord::Migration
  def change
    create_table :schools do |t|
      t.string :lat
      t.string :lon
      t.string :address
      t.string :name

      t.timestamps
    end
  end
end
