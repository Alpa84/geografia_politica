module MapsHelper
  LOW_COLOR  = 0x000000 
  HIGH_COLOR = 0xFF7700
  SAMPLES = 100
  FILL_OPACITY = 1
  RADIUS = 250
  PERCENTAGE = 100
  GRADIENT = Gradient.new( LOW_COLOR, HIGH_COLOR, SAMPLES)

  def labels( circle_group, labels_divisions = 5)
    increment = ((circle_group.max - circle_group.min ).to_f / (labels_divisions - 1 ) )
    labels_values = labels_divisions.times.collect do |time|
      label_value = (circle_group.max - (increment * time))
      (circle_group.max - circle_group.min) < 0.06 ? decimals = 2 : decimals = 0
      label_percentage = (label_value * 100).round(decimals).to_s
      '<p>' + label_percentage + '%' + '</p>'+ "<p class='lab#{time} labels'> ● "
    end.join('<br>').html_safe
  end

  def public_offices_plus_one
    PublicOffice.all.order(:name).collect {|p| [ p.name.humanize, p.id ]} + [['Todos los Cargos', 0] ] 
  end
  
  def partidos_drop
    partidos_list = PoliticalParty.all.order(:name).collect { |party| [ party.name.humanize, party.id ]}
    partidos_list.each do |part|
      case part[1]
      when 4
        part[0] <<' (Part. Socialista)'
      when 3
        part[0] << ' (Kirchnerismo)'
      when 2
        part[0] << ' (PRO)'
      end
    end
  end

  def create_leaflet_hash(circle)
    
    votes_schools = circle.votes_schools
    return nil if circle.max == 0

    votes_range = circle.max - circle.min

    leaflet = votes_schools.collect do |vote_school|
      votes = vote_school.votes
      total = vote_school.school.total
      lat = vote_school.school.lat
      lon = vote_school.school.lon
      ratio = (votes.to_f / total)
      intensity = (ratio - circle.min ) * PERCENTAGE / votes_range
      color = "#" + GRADIENT.gradient(intensity).to_s(16)
      school_name = vote_school.school.name
      popup = "<b>#{(ratio*100).round(2)}%</b> de este local electoral, <br><b>#{votes}</b> votos de un total de <b>#{total}</b>, <br>#{school_name} ".gsub(/[°()\'\"]/i, '') 
      circles = {:ratio => ratio, :latlng => [lon, lat], :popup => popup ,:radius => RADIUS, :fillOpacity  => FILL_OPACITY,:color => color, :fillColor => color } 
    end
    
    circle.sorted ? leaflet.sort_by { |circle| circle[:ratio]} : leaflet
  end

end


