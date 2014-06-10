class VotesTotal < ActiveRecord::Base
  belongs_to :school
  belongs_to :political_party
  belongs_to :public_office

  def self.votes_per_school(party_and_office) 
    VotesTotal.includes(:school).where(political_party_id:party_and_office['party_id'], public_office_id:party_and_office['public_office_id']).references(:school)
  end
  def self.party_totals_per_school(party)
    VotesTotal.includes(:school).where(political_party_id:party['party_id']).references(:school).group(:school_id).sum(:votes)
  end
end
