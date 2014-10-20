require "rails_helper"


describe "the schools interface", :type => :feature do

  before :each do
    school = School.create!(name: 'Sarmiento', address: 'rioja 123' , lat: '33', lon: '5', total: 44)
    school_id = school.id
    VotesTotal.create!(school_id: school_id, votes: 3, political_party_id: 65, public_office_id: 0 )
    VotesTotal.create!(school_id: school_id, votes: 3, political_party_id: 65, public_office_id: 0 )
    VotesTotal.create!(school_id: school_id, votes: 3, political_party_id: 3, public_office_id: 0 )
    VotesTotal.create!(school_id: school_id, votes: 3, political_party_id: 4, public_office_id: 0 )
    VotesTotal.create!(school_id: school_id, votes: 3, political_party_id: 2, public_office_id: 0 )
    VotesTotal.create!(school_id: school_id, votes: 3, political_party_id: 5, public_office_id: 1 )

    PublicOffice.create!(name: 'just an example office')
   
  end

  it "signs me in" do
    visit '/'
    expect(page).to have_content 'Política'
  end
end