#Prepares votes of each school to work with #create_leaflet_hash in maps_helper

class CircleGroup

  attr_reader :votes_schools, :max, :min , :sorted
  
  def initialize(selected, sorted = false)
    
    @sorted = sorted    
    @votes_schools = VotesTotal.votes_per_school(selected)
    @max = votes_schools.map do |votes_school| 
      votes_school.nil? ? 0 : votes_school.votes / votes_school.school.total.to_f
    end.max
    
    @max == 0 ? @min = 0 : @min = votes_schools.map { |votes_school| votes_school.votes / votes_school.school.total.to_f}.min
  end
end