require "rails_helper"

RSpec.describe MapsController, :type => :controller do

  describe "GET #index" do
    it "responds successfully with an HTTP 200 status code" do
    school = School.create!(name: 'Sarmiento', address: 'rioja 123' , lat: '33', lon: '5', total: 44)
    school_id = school.id
    total_a = VotesTotal.create!(school_id: school_id, votes: 3, political_party_id: 65, public_office_id: 2 )
    total_b = VotesTotal.create!(school_id: school_id, votes: 3, political_party_id: 65, public_office_id: 2 )
   
      get :index
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template("index")
    end

    it "loads the default votes in @requested_circles object" do
      school = School.create!(name: 'Sarmiento', address: 'rioja 123' , lat: '33', lon: '5', total: 44)
      school_id = school.id
      total_a = VotesTotal.create!(school_id: school_id, votes: 3, political_party_id: 65, public_office_id: 2 )
      total_b = VotesTotal.create!(school_id: school_id, votes: 3, political_party_id: 65, public_office_id: 2 )
      PublicOffice.create!(name: 'just an example office')
      get :index
      expect(assigns(:requested_circles).votes_schools[0].votes).to eq(6)
      expect(assigns(:requested_circles).sorted).to eq(false)
      expect(assigns(:requested_circles).min).to eq(6/44.0)
      expect(assigns(:requested_circles).max).to eq(6/44.0)
    end

    it "loads the  requestedvotes in @requested_circles object" do
      school = School.create!(name: 'Sarmiento', address: 'rioja 123' , lat: '33', lon: '5', total: 44)
      school_id = school.id
      total_a = VotesTotal.create!(school_id: school_id, votes: 8, political_party_id: 3, public_office_id: 1 )
      total_b = VotesTotal.create!(school_id: school_id, votes: 3, political_party_id: 65, public_office_id: 2 )
      PublicOffice.create!(name: 'just an example office')
      get :index, {"utf8"=>"✓",
                   "partido"=>{"political_party_id"=>"3"},
                   "cargo"=>{"public_office_id"=>"1"},
                   "commit"=>"Mostrar",
                   "controller"=>"maps",
                   "action"=>"index"}
      expect(assigns(:requested_circles).votes_schools[0].votes).to eq(8)
      expect(assigns(:requested_circles).sorted).to eq(false)
    end
  end
end