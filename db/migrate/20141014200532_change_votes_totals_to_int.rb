class ChangeVotesTotalsToInt < ActiveRecord::Migration
  def change
    reversible do |dir|
      change_table :votes_totals do |t|
        dir.up   { t.change :votes, :string }
        dir.down { t.change :votes, :integer }
      end
    end
  end
end
