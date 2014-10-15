class CorrectVotesTotalsType < ActiveRecord::Migration
  def up
    connection.execute(%q{
      alter table votes_totals
      alter column votes
      type integer using cast(votes as integer)
    })
  end
end
