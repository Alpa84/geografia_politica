class CreateVotesTotals < ActiveRecord::Migration
  def change
    create_table :votes_totals do |t|
      t.references :school, index: true
      t.references :political_party, index: true
      t.references :public_office, index: true
      t.string :votes

      t.timestamps
    end
  end
end
