require "rails_helper"


RSpec.describe VotesTotal, :type => :model do
  
  before :each do

  end

  it "should get the right votes" do
    school = School.create!(name: 'Sarmiento', address: 'rioja 123' , lat: '33', lon: '5', total: 44)
    school_id = school.id
    total_a = VotesTotal.create!(school_id: school_id, votes: 3, political_party_id: 65, public_office_id: 2 )
    total_b = VotesTotal.create!(school_id: school_id, votes: 3, political_party_id: 65, public_office_id: 2 )
    public_office = PublicOffice.create!(name: 'the party of the example')

    expect(VotesTotal.votes_per_school({'party_id' => 65, 'public_office_id' => 2 })).to eq([total_a, total_b])
    expect(VotesTotal.votes_per_school({'party_id' => 65, 'public_office_id' => 2 }).first.school).to eq(school)
    expect(VotesTotal.votes_per_school({'party_id' => 65}).first.votes).to eq(6)
  end
end