class PoliticalParty < ActiveRecord::Base
  has_many :votes_totals
end
