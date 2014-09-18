file = File::open( "vendor/assets/resultados_yaml.txt", "r" ) 
string  = file.read
restaurado = YAML.load string

distancias = {}
School.all.each do |school|
  School.all.each do |compare_school|
    unless school.id == compare_school.id
      a = school.lat.to_f - compare_school.lat.to_f
      b = school.lon.to_f - compare_school.lon.to_f
      distancia = Math.hypot(a,b)
      distancias[distancia] = [[school.name, school.id], [compare_school.name, compare_school.id]]
    end
  end
end

orden = distancias.sort_by {|_key, value| _key}
sumar_inclusive = orden[8]

repetidos = [[222, 223], [84,77], [7,6], [207, 202], [28, 27], [47,46], [163,158], [235, 231], [16, 14] ]
a_ser_sumado = [223, 77, 6, 202, 27, 46, 158, 231, 14]
a_modificar_ary = [222, 84, 7, 207, 207, 28, 47, 163, 235, 16]



id_part_existentes = PoliticalParty.all.collect do |part|
  part.id
end



restaurado.each do |local|
  encontrado = School.where(name:local[0][2])
  if a_ser_sumado.include? encontrado[0].id
    local[1].each_with_index do |partido, index|
      sucesion = index + 1
      if id_part_existentes.include? sucesion
        partido[1].each_with_index do |cargo, ind_dos|
          vote = VotesTotal.new
          vote.political_party_id = sucesion
          vote.school_id = encontrado[0].id
          vote.public_office_id =ind_dos + 1 
          vote.votes = cargo
          vote.save
        end
      end
    end
  end
end

a_ser_sumado.each do |id_a_s|
  School.find(id_a_s)

end

### en construccion

a_modificar = School.find(222)
a_sumar = School.find(223)
a_modificar.name += " + #{a_sumar.name}" 

VotesTotal.where(school_id:222).each do |vot_esc|
  vot_esc.where
local[1].each_with_index do |partido, index|
  sucesion = index + 1
  if id_part_existentes.include? sucesion
      partido[1].each_with_index do |cargo, ind_dos|
      suc_2 = ind_dos + 1
      vote = VotesTotal.where(school_id:, political_party_id:sucesion, public_office_id:suc_2)
      vote.political_party_id = sucesion
      vote.school_id = 
      vote.public_office_id =suc_2 
      vote.votes += cargo
      vote.save
    end
  end
end



#--------------- para sumar Rizzori id 244
VotesTotal.where(school_id:244)

restaurado.each do |local|
  encontrado = School.where(name:local[0][2])
  if a_ser_sumado.include? encontrado[0].id
    local[1].each_with_index do |partido, index|
      sucesion = index + 1
      if id_part_existentes.include? sucesion
        partido[1].each_with_index do |cargo, ind_dos|
          vote = VotesTotal.new
          vote.political_party_id = sucesion
          vote.school_id = encontrado[0].id
          vote.public_office_id =ind_dos + 1 
          vote.votes = cargo
          vote.save
        end
      end
    end
  end
end

public_offices = [1,2,3,4,5]
party_ides = [1,2,3,4,5,6,20,31,37,51,54,56,65,66]

party_ides.each do |part_id|

  votes_party = VotesTotal.where(school_id:2).where(political_party_id:part_id)
  public_offices.each do |pub_id|
    votos_a_sumar = votes_party.where(public_office_id:pub_id)
    resultado = votos_a_sumar[0].votes.to_i + votos_a_sumar[1].votes.to_i
    votos_a_sumar[0].votes = resultado
    votos_a_sumar[0].save
    votos_a_sumar[1].destroy
  end

end