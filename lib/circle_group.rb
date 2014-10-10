#add comment, que hace la clase

#trasformar a objecto instanciable
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