class BienvenidosController < ApplicationController

LOW_COLOR  = 0x000000 
HIGH__COLOR = 0xFFFF00
SAMPLES = 100
LEGEND_SAMPLES = 5
  def index
    @color = "#0B6138"
    @legend_samples = LEGEND_SAMPLES
    if params['partido'].blank? || params['partido']['political_party_id'].blank?
      @partido_seleccionado = PoliticalParty.first
      @partido_seleccionado_name = @partido_seleccionado['name'].humanize
    else 
      @partido_seleccionado = PoliticalParty.where(id:params['partido']["political_party_id"])[0]
      @partido_seleccionado_name  = @partido_seleccionado['name'].humanize
    end
    if params['cargo'].blank? || params['cargo']["public_office_id"].blank?
      @cargo_seleccionado = PublicOffice.first
      @cargo_seleccionado_name = @cargo_seleccionado['name'].humanize
    else
      @cargo_seleccionado = PublicOffice.where(id:params['cargo']["public_office_id"])[0]
      @cargo_seleccionado_name  = @cargo_seleccionado['name'].humanize
    end
 
    @gradient = Gradient.new( LOW_COLOR, HIGH__COLOR, SAMPLES)
    @all_circles = circulos_de_intensidad({'cargo_id' => @cargo_seleccionado.id, 'partido_id' => @partido_seleccionado.id})
    @fein_circles = circulos_de_intensidad({'cargo_id' => 5, 'partido_id' => 4})
    @miguel_circles = circulos_de_intensidad({'cargo_id' => 6, 'partido_id' => 4})
    @intendente_pro_circles = circulos_de_intensidad({'cargo_id' => 5, 'partido_id' => 2})
    
    @pro_circles = circulos_partido({'partido_id' => 2})
    @socialismo_circles = circulos_partido({'partido_id' => 4})
    @k_circles = circulos_partido({'partido_id' => 3})
  end
end

def circulos_de_intensidad(selected = {'cargo_id' => 1, 'partido_id' => 1})
  votes_for_party = VotesTotal.where(political_party_id:selected['partido_id'])
  leaflet = {}
  max = 0
  min = 0
  total = 0
  leaflet = School.all.collect do |school|

    votes = votes_for_party.where(public_office_id:selected['cargo_id']).where(school_id:school.id)[0].votes.to_f
    max = votes_for_party.maximum('votes')
    min = votes_for_party.minimum('votes')
    total = school.total
    lat = school.lat
    lon = school.lon
    leaflet_circles({'intensity' => votes, 'total' => total, 'min'=> min , 'max' => max, 'lat' => lat, 'lon' => lon})
  end
  labels = labels_a({:min => min, :max => max, :total => total})
  { :leaflet => leaflet, :labels => labels}
end


 
def circulos_partido(selected = {'partido_id' => 1})
  max = 0
  min = nil
  total = 0
  leaflet = {}
  School.all.collect do |school|
    votes_for_party = VotesTotal.where(political_party_id:selected['partido_id'])
    separed_votes = votes_for_party.where(school_id:school.id)
    added_votes = 0
    separed_votes.each do |i_votes|
      added_votes += i_votes.votes
    end
    max = added_votes if added_votes > max
    min = added_votes if min.nil?
    min = added_votes if added_votes < min

  end

  leaflet = School.all.collect do |school|
    votes_for_party = VotesTotal.where(political_party_id:selected['partido_id'])
    separed_votes = votes_for_party.where(school_id:school.id)
    added_votes = 0
    separed_votes.each do |i_votes|
      added_votes += i_votes.votes
    end

    total = school.total
    lat = school.lat
    lon = school.lon

    leaflet_circles({'intensity' => added_votes, 'total' => total, 'min'=> min , 'max' => max, 'lat' => lat, 'lon' => lon})
  end
    labels = labels_a({:min => min, :max => max, :total => total})
  { :leaflet => leaflet, :labels => labels}
end

def leaflet_circles (circles)
    fraction = circles['intensity'] / circles['total']
    intensity = 100 * (fraction - (circles['min'].to_f / circles['total']) ) / ( (circles['max'].to_f / circles['total']) - ( circles['min'].to_f / circles['total'] ) ) 
    intensity = 0 if intensity < 0
    intensity = 5000 if intensity > 5000
    {:latlng => [circles['lon'], circles['lat']],
     :radius => 200, :color =>"##{@gradient.gradient(intensity).to_s(16)}", :fillColor => "##{@gradient.gradient(intensity).to_s(16)}",
     :fillOpacity =>  0.5 }
 end

def labels_a ( min_max)
  increment = (min_max[:max] - min_max[:min] ).to_f / @legend_samples
  lab_arr = []
  @legend_samples.times do |time|
    lab_arr.push ((min_max[:max] - (increment * time) ) /  min_max[:total])
  end
  lab_arr
end

