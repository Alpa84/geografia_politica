require "rails_helper"

RSpec.describe MapsController
describe 'CircleGroup' do

  it '' do
    votes = [OpenStruct.new(votes: 3, school: OpenStruct.new(total: 20))]
    VotesTotal.stub(:votes_per_school) {votes}
    circle_group = CircleGroup.new({'public_office_id' => 3, 'party_id' => 4})
    
    expect(circle_group.max).to eq(0.15)
    expect(circle_group.min).to eq(0.15)
    expect(circle_group.sorted).to eq(false)
    expect(circle_group.votes_schools).to eq(votes)


  end
end

