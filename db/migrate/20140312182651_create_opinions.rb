class CreateOpinions < ActiveRecord::Migration
  def change
    create_table :opinions do |t|
      t.text :mensaje
      t.text :autor

      t.timestamps
    end
  end
end
