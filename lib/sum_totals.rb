
schools = School.all

school_indexes = *(2..244)

school_indexes.each do |index|
  binding.pry
  school = School.find(index)
  votos_a_un_mismo_cargo_de_una_escuela = VotesTotal.where( school_id: index).where( public_office_id: 6).all
  total_por_escuela = 0
  votos_a_un_mismo_cargo_de_una_escuela.each do |votos|
    total_por_escuela += votos.votes
  end
  school.total = total_por_escuela
  school.save
end

p 'trabajo terminado, maestro'

# poner en orden el ide de los cargos y ver si despues se corresponde con lo que se pide