require 'uri'

class BienvenidosController < ApplicationController

LOW_COLOR  = 0x000000 
HIGH__COLOR = 0xFFFFFF
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

    @constructed_java = alt_map(:container_id => "map",:center => {:latlng => [-32.954088, -60.664458],:zoom => 12 }, 
     :circles => [{:latlng => [-32.954088, -60.664458],
     :radius => 200, :color =>"##{@gradient.gradient(2).to_s(16)}", :fillColor => "##{@gradient.gradient(3).to_s(16)}",
     :fillOpacity =>  0.5 ,
     :popup => 'lolo'
     } , {:latlng => [-32.964088, -60.664458],
     :radius => 300, :color =>"##{@gradient.gradient(2).to_s(16)}", :fillColor => "##{@gradient.gradient(3).to_s(16)}",
     :fillOpacity =>  0.5 ,
     :popup => 'lolo'
     }]
     )


    @all_circles = circulos_de_intensidad({'cargo_id' => @cargo_seleccionado.id, 'partido_id' => @partido_seleccionado.id})
    @all_circles_map = alt_map(:container_id => "map1",
    :center => {:latlng => [-32.954088, -60.664458],:zoom => 12 },
    :circles =>  @all_circles[:leaflet])
    @fein_circles = circulos_de_intensidad({'cargo_id' => 4, 'partido_id' => 4})
    @miguel_circles = circulos_de_intensidad({'cargo_id' => 2, 'partido_id' => 4})
    @intendente_pro_circles = circulos_de_intensidad({'cargo_id' => 5, 'partido_id' => 2})
    
    @pro_circles = circulos_partido({'partido_id' => 2})
    @pro_map = alt_map(:container_id => "map2",
    :center => {:latlng => [-32.954088, -60.664458],:zoom => 12 },
    :circles =>  @pro_circles[:leaflet])

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
  leaflet_without_interpolation = School.all.collect do |school|

    votes = votes_for_party.where(public_office_id:selected['cargo_id']).where(school_id:school.id)[0].votes
    total = school.total
    max = votes_for_party.where(public_office_id:selected['cargo_id']).maximum('votes')
    min = votes_for_party.where(public_office_id:selected['cargo_id']).minimum('votes')
    lat = school.lat
    lon = school.lon
    ratio = (votes.to_f / total )
    popup = "#{ratio} ratio, #{votes} votos, #{total} total, #{max}max, #{min} min   #{school.id} id#{school.name} ".gsub(/[^0-9a-z ]/i, '') 
    leaflet_circles({'intensity' => ratio, 'total' => total, 'min'=> min , 'max' => max, 'lat' => lat, 'lon' => lon, 'popup' => popup })

  end
  leaflet = interpolate_range(leaflet_without_interpolation, 100)
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
    ratio = added_votes/total
    lat = school.lat
    lon = school.lon
    ratio = (added_votes.to_f / total *5 )
    popup = "#{ratio} ratio, #{added_votes} votos \n #{school.name} #{school.address}".gsub(/[^0-9a-z ]/i, '')
    leaflet_circles({'intensity' => ratio, 'total' => total, 'min'=> min , 'max' => max, 'lat' => lat, 'lon' => lon, 'popup' => popup})
  end
    labels = labels_a({:min => min, :max => max, :total => total})
  { :leaflet => leaflet, :labels => labels}
end

def leaflet_circles (circles)
    fraction = circles['intensity']
    intensity = 100 * (fraction - (circles['min'].to_f / circles['total']) ) / ( (circles['max'].to_f / circles['total']) - ( circles['min'].to_f / circles['total'] ) ) 
    intensity = 0 if intensity < 0
    intensity = 5000 if intensity > 5000
    intensity = circles['intensity']*100
    {:latlng => [circles['lon'], circles['lat']],
     :radius => 200, 
     :color =>"##{@gradient.gradient(intensity).to_s(16)}", 
     :fillColor => "##{@gradient.gradient(intensity).to_s(16)}",
     :fillOpacity =>  1 , 
     :popup => circles['popup'],
     :ratio => circles['intensity'] }
 end

def labels_a ( min_max)
  increment = (min_max[:max] - min_max[:min] ).to_f / @legend_samples
  lab_arr = []
  @legend_samples.times do |time|
    lab_arr.push ((min_max[:max] - (increment * time) ) /  min_max[:total])
  end
  lab_arr
end

def interpolate_range(circles, samples)
  ratios = circles.collect { |cada| cada[:ratio]}
  min = ratios.sort[0]
  max =  ratios.sort[-1]
  range = max - min
  with_proper_colors = circles.collect do |circle| 
    intensity = (circle[:ratio] - min ) * samples / range
    circle[:color] = "##{@gradient.gradient(intensity).to_s(16)}"
    circle[:fillColor] = "##{@gradient.gradient(intensity).to_s(16)}"
    circle
  end
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
        }"
      if circle[:popup]
         output.last << ").bindPopup(String('#{circle[:popup]}'))"
      end
      output.last << '.addTo(map);'
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
