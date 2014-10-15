class VotesTotal < ActiveRecord::Base
  belongs_to :school
  belongs_to :political_party
  belongs_to :public_office

  def self.votes_per_school(selected)
    if selected['public_office_id'].present? && selected['public_office_id'] != '0'
      public_office_per_school(selected)
    else
      party_totals_per_school(selected)
    end    
  end

  def self.public_office_per_school(party_and_office) 
    VotesTotal.includes(:school).where(political_party_id:party_and_office['party_id'], public_office_id:party_and_office['public_office_id']).references(:school)
  end
  
  def self.party_totals_per_school(party)
    school_partials = VotesTotal.includes(:school).where(political_party_id:party['party_id']).references(:school).group(:school_id).sum(:votes)
    School.all.collect do |school|
      votes = school_partials[school.id]
      total = school.total * PublicOffice.count
      OpenStruct.new(votes: votes, school: OpenStruct.new( total: total , lat: school.lat, lon: school.lon, name: school.name))
    end
  end
end
