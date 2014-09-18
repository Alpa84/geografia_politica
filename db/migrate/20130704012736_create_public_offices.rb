class CreatePublicOffices < ActiveRecord::Migration
  def change
    create_table :public_offices do |t|
      t.string :name

      t.timestamps
    end
  end
end
