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
    @all_circles_map = AltLeaflet.alt_map(:container_id => "map_all",
    :center => {:latlng => [-32.954088, -60.664458],:zoom => 12 },
    :circles =>  @all_circles[:leaflet])

    @fein_circles = circulos_de_intensidad({'cargo_id' => 4, 'partido_id' => 4})
    @fein_circles_map = AltLeaflet.alt_map(:container_id => "map_fein",
    :center => {:latlng => [-32.954088, -60.664458],:zoom => 12 },
    :circles =>  @fein_circles[:leaflet])

    @miguel_circles = circulos_de_intensidad({'cargo_id' => 2, 'partido_id' => 4})
    @miguel_circles_map = AltLeaflet.alt_map(:container_id => "map_mig",
    :center => {:latlng => [-32.954088, -60.664458],:zoom => 12 },
    :circles =>  @miguel_circles[:leaflet])

    @castells_circles = circulos_de_intensidad({'cargo_id' => 1, 'partido_id' => 5})
    @castells_circles_map = AltLeaflet.alt_map(:container_id => "map_castells",
    :center => {:latlng => [-32.94,-60.66],:zoom => 13 },
    :circles =>  @castells_circles[:leaflet])

    @pro_circles = circulos_de_intensidad({'partido_id' => 2})
    @pro_map = AltLeaflet.alt_map(:container_id => "map_pro",
    :center => {:latlng => [-32.954088, -60.664458],:zoom => 12 },
    :circles =>  @pro_circles[:leaflet])

    @socialismo_circles = circulos_de_intensidad({'partido_id' => 4})
    @socialismo_circles_map = AltLeaflet.alt_map(:container_id => "map_soc",
    :center => {:latlng => [-32.954088, -60.664458],:zoom => 12 },
    :circles =>  @socialismo_circles[:leaflet])

    @k_circles = circulos_de_intensidad({'partido_id' => 3})
    @k_circles_map = AltLeaflet.alt_map(:container_id => "map_k",
    :center => {:latlng => [-32.954088, -60.664458],:zoom => 12 },
    :circles =>  @k_circles[:leaflet])
  end
end

def circulos_de_intensidad(selected = {'partido_id' => 1})

  if selected['cargo_id'] and selected['cargo_id'] != 't'
    #votes_schools = VotesTotal.joins(:school).where(political_party_id:selected['partido_id'], public_office_id:selected['cargo_id'])
    votes_schools = VotesTotal.includes(:school).where(political_party_id:selected['partido_id'], public_office_id:selected['cargo_id']).references(:school)
    leaflet_without_interpolation = votes_schools.collect do |vote_school|
      votes = vote_school.votes
      total = vote_school.school.total
      lat = vote_school.school.lat
      lon = vote_school.school.lon
      ratio = (votes.to_f / total)
      school_name = vote_school.school.name
      popup = "<b>#{(ratio*100).round(2)}%</b> de este local electoral, <br><b>#{votes}</b> votos de un total de <b>#{total}</b>, <br>#{school_name} ".gsub(/[°()\'\"]/i, '') 
      leaflet_circles({'ratio' => ratio, 'lat' => lat, 'lon' => lon, 'popup' => popup })
    end
  else
    parties_partials = VotesTotal.includes(:school).where(political_party_id:selected['partido_id']).references(:school).group(:school_id).sum(:votes)
    #parties_partials = VotesTotal.joins(:school).where(political_party_id:selected['partido_id']).group(:school_id).sum(:votes)
    schools = School.all
    leaflet_without_interpolation = schools.collect do |school|
      votes = parties_partials[school.id]
      total = school.total * 5
      lat = school.lat
      lon = school.lon
      ratio = (votes.to_f / total)
      popup = "<b>#{(ratio*100).round(2)}%</b> de este local electoral, <br><b>#{votes}</b> votos de un total de <b>#{total}</b>, <br>#{school.name} ".gsub(/[°()\'\"]/i, '') 
      leaflet_circles({'ratio' => ratio, 'lat' => lat, 'lon' => lon, 'popup' => popup })

    end
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

