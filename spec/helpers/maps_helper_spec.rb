require "rails_helper"

RSpec.describe ApplicationHelper do
  describe "index" do
    it "returns labels" do
      circle_group = OpenStruct.new(max: 5, min:0)

      expect(helper.labels(circle_group)).to eq("<p>500%</p><p class='lab0 labels'> ● <br><p>375%</p><p class='lab1 labels'> ● <br><p>250%</p><p class='lab2 labels'> ● <br><p>125%</p><p class='lab3 labels'> ● <br><p>0%</p><p class='lab4 labels'> ● ")
    end

    it "adds ['Todos los Cargos'] in public offices array" do
      expect(helper.public_offices_plus_one).to eq([['Todos los Cargos', 0]])
    end

    it "should build a hash to pass to leaflet gem" do
      circle = OpenStruct.new(max:5, min:0 , votes_schools: [OpenStruct.new(votes: 5, school: OpenStruct.new(total: 44, lat:43, lon:32, name: ' Sarmientino'))])
      expect(helper.create_leaflet_hash(circle)).to eq(
        [{:ratio=>0.11363636363636363,
          :latlng=>[32, 43],
          :popup=>
           "<b>11.36%</b> de este local electoral, <br><b>5</b> votos de un total de <b>44</b>, <br> Sarmientino ",
          :radius=>250,
          :fillOpacity=>1,
          :color=>"#60300",
          :fillColor=>"#60300"}]
        )
    end

  end
end