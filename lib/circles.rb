class Circles
  LOW_COLOR  = 0x000000 
  HIGH__COLOR = 0xFF7700
  SAMPLES = 100
  @fillOpacity = 1
  @radius = 250
  @gradient = Gradient.new( LOW_COLOR, HIGH__COLOR, SAMPLES)
  def self.circles_and_labels(selected, sorted = false)
    votes_schools = VotesTotal.votes_per_school(selected)
    max = votes_schools.map do |votes_school| 
      votes_school = 0 if votes_school.nil?
      votes_school.votes / votes_school.school.total.to_f
    end
    max = max.max  ######## TODO rename
    return { :leaflet => nil, :labels => {:min => 0, :max => 0} } if max == 0
    min = votes_schools.map {|votes_school| votes_school.votes / votes_school.school.total.to_f}
    min = min.min #### TODO rename
    votes_range = max - min

    leaflet = votes_schools.collect do |vote_school|
      votes = vote_school.votes
      total = vote_school.school.total
      lat = vote_school.school.lat
      lon = vote_school.school.lon
      ratio = (votes.to_f / total)
      intensity = (ratio - min ) * 100 / votes_range
      color = "#" + @gradient.gradient(intensity).to_s(16)
      school_name = vote_school.school.name
      popup = "<b>#{(ratio*100).round(2)}%</b> de este local electoral, <br><b>#{votes}</b> votos de un total de <b>#{total}</b>, <br>#{school_name} ".gsub(/[°()\'\"]/i, '') 
      circles = {:ratio => ratio, :latlng => [lon, lat], :popup => popup ,:radius => @radius, :fillOpacity  => @fillOpacity,:color => color, :fillColor => color } 
    end
    leaflet = leaflet.sort_by { |circle| circle[:ratio]} if sorted
    { :leaflet => leaflet, :labels => {:min => min, :max => max} }
  end

end