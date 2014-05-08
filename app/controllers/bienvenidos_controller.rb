class BienvenidosController < ApplicationController

LOW_COLOR  = 0x000000 
HIGH__COLOR = 0xFFFF00
SAMPLES = 100
LEGEND_SAMPLES = 5
  def index

    @constructed_java = alt_map(:container_id => "map",:center => {:latlng => [-32.954088, -60.664458],:zoom => 12 },:custom_marker => 'algo', :markers => [{ :latlng => [-32.954088, -60.664458], :popup => "el popup de prueben"}])


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

#-------------------------


def alt_map(options)
  options[:tile_layer] ||= Leaflet.tile_layer
  options[:attribution] ||= Leaflet.attribution
  options[:max_zoom] ||= Leaflet.max_zoom
  options[:container_id] ||= 'map'

  output = []
  output << "<div id='#{options[:container_id]}'></div>" unless options[:no_container]
  output << "<script>"
  output << "var map = L.map('#{options[:container_id]}')"
  
  if options[:custom_marker]
    output << "var greenIcon = L.icon({
    iconUrl: 'leaf-green.png',
    shadowUrl: 'leaf-shadow.png',

    iconSize:     [38, 95], // size of the icon
    shadowSize:   [50, 64], // size of the shadow
    iconAnchor:   [22, 94], // point of the icon which will correspond to marker's location
    shadowAnchor: [4, 62],  // the same for the shadow
    popupAnchor:  [-3, -76] // point from which the popup should open relative to the iconAnchor
    });"

  end

  if options[:center]
    output << "map.setView([#{options[:center][:latlng][0]}, #{options[:center][:latlng][1]}], #{options[:center][:zoom]})"
  end


  if options[:markers]
    options[:markers].each do |marker|
      output << "marker = L.marker([#{marker[:latlng][0]}, #{marker[:latlng][1]}]"
      if options[:custom_marker]
        output.last << ", {icon: greenIcon}" 
      end
      output.last << ").addTo(map)"
      if marker[:popup]
        output << "marker.bindPopup('#{marker[:popup]}')"
      end
    end
  end

  if options[:circles]
    options[:circles].each do |circle|
      output << "L.circle(['#{circle[:latlng][0]}', '#{circle[:latlng][1]}'], #{circle[:radius]}, {
color: '#{circle[:color]}',
fillColor: '#{circle[:fillColor]}',
fillOpacity: #{circle[:fillOpacity]}
}).addTo(map);"
    end
  end

  if options[:polylines]
     options[:polylines].each do |polyline|
       _output = "L.polyline(#{polyline[:latlngs]}"
       _output << "," + polyline[:options].to_json if polyline[:options]
       _output << ").addTo(map);"
       output << _output.gsub(/\n/,'')
     end
  end

  if options[:fitbounds]
    output << "map.fitBounds(L.latLngBounds(#{options[:fitbounds]}));"
  end

  output << "L.tileLayer('#{options[:tile_layer]}', {
attribution: '#{options[:attribution]}',
maxZoom: #{options[:max_zoom]}
}).addTo(map)"
  output << "</script>"
  output.join("\n").html_safe
end
