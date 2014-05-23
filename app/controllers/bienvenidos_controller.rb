require 'uri'

class BienvenidosController < ApplicationController

LOW_COLOR  = 0x000000 
HIGH__COLOR = 0xFF7700
SAMPLES = 100
LEGEND_SAMPLES = 5
  def index
    @public_offices_plus_one = PublicOffice.all.order(:name).collect {|p| [ p.name.humanize, p.id ]} + [['Todos los Cargos', 't'] ]
    @partidos_drop = PoliticalParty.all.order(:name).collect {|p| [ p.name.humanize, p.id ]}
    @partidos_drop.each do |part|
      case part[1]
      when 4
        part[0] = [part[0], ' (Part. Socialista)'].join
      when 3
        part[0] = [part[0], ' (Kirchnerismo)'].join
      when 2
        part[0] = [part[0], ' (PRO)'].join
      end
    end

  
    @legend_samples = LEGEND_SAMPLES
    if params['partido'].blank? 
      @partido_id = 66
      @cargo_id = 2
    else
      @partido_id = params['partido']['political_party_id']
      @cargo_id = params['partido']['public_office_id']
    end
 
    @gradient = Gradient.new( LOW_COLOR, HIGH__COLOR, SAMPLES)
    @all_circles = circulos_de_intensidad({'cargo_id' => @cargo_id, 'partido_id' => @partido_id})
    @all_circles_map = alt_map(:container_id => "map_all",
    :center => {:latlng => [-32.954088, -60.664458],:zoom => 12 },
    :circles =>  @all_circles[:leaflet])

    @fein_circles = circulos_de_intensidad({'cargo_id' => 4, 'partido_id' => 4})
    @fein_circles_map = alt_map(:container_id => "map_fein",
    :center => {:latlng => [-32.954088, -60.664458],:zoom => 12 },
    :circles =>  @fein_circles[:leaflet])

    @miguel_circles = circulos_de_intensidad({'cargo_id' => 2, 'partido_id' => 4})
    @miguel_circles_map = alt_map(:container_id => "map_mig",
    :center => {:latlng => [-32.954088, -60.664458],:zoom => 12 },
    :circles =>  @miguel_circles[:leaflet])

    @castells_circles = circulos_de_intensidad({'cargo_id' => 1, 'partido_id' => 5})
    @castells_circles_map = alt_map(:container_id => "map_castells",
    :center => {:latlng => [-32.94,-60.66],:zoom => 13 },
    :circles =>  @castells_circles[:leaflet])

    @pro_circles = circulos_de_intensidad({'partido_id' => 2})
    @pro_map = alt_map(:container_id => "map_pro",
    :center => {:latlng => [-32.954088, -60.664458],:zoom => 12 },
    :circles =>  @pro_circles[:leaflet])

    @socialismo_circles = circulos_de_intensidad({'partido_id' => 4})
    @socialismo_circles_map = alt_map(:container_id => "map_soc",
    :center => {:latlng => [-32.954088, -60.664458],:zoom => 12 },
    :circles =>  @socialismo_circles[:leaflet])

    @k_circles = circulos_de_intensidad({'partido_id' => 3})
    @k_circles_map = alt_map(:container_id => "map_k",
    :center => {:latlng => [-32.954088, -60.664458],:zoom => 12 },
    :circles =>  @k_circles[:leaflet])
  end
end

def circulos_de_intensidad(selected = {'partido_id' => 1})
  votes_for_party = VotesTotal.where(political_party_id:selected['partido_id'])
  leaflet_without_interpolation = School.all.collect do |school|
    if selected['cargo_id'] and selected['cargo_id'] != 't'
      votes = votes_for_party.where(public_office_id:selected['cargo_id']).where(school_id:school.id)[0].votes
      total = school.total
    else
      votes = 0
      all_offices_votes = votes_for_party.where(school_id:school.id).each do |office_votes|
        votes += office_votes.votes
      end
      total = school.total * 5
    end
    lat = school.lat
    lon = school.lon
    ratio = (votes.to_f / total)
    popup = "#{(ratio*100).round(2)}% de este local electoral, #{votes} votos de un total de #{total}, #{school.name} ".gsub(/[°()\'\"]/i, '') 
    leaflet_circles({'ratio' => ratio, 'lat' => lat, 'lon' => lon, 'popup' => popup })

  end
  leaflet = interpolate_range(leaflet_without_interpolation, 100)
  labels = labels_a({:min => leaflet[:min], :max => leaflet[:max]})
  { :leaflet => leaflet[:circles], :labels => labels}
end
 

def leaflet_circles (circles)
    {:latlng => [circles['lon'], circles['lat']],
     :radius => 200, 
     :fillOpacity =>  1 , 
     :popup => circles['popup'],
     :ratio => circles['ratio'] }
 end

def labels_a ( min_max)
  increment = ((min_max[:max] - min_max[:min] ).to_f / (@legend_samples -1  ) )
  lab_arr = []
  @legend_samples.times do |time|
    lab_arr.push (min_max[:max] - (increment * time))
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
  {:circles => with_proper_colors, :max => max, :min => min}
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
