all_part_id =  *(1..66)
partidos_a_borrar = []
all_part_id.each do |part_id|
  if VotesTotal.where(political_party_id:part_id).maximum('votes') == 0
    partidos_a_borrar.push part_id 
  end
end

partidos_a_borrar.each do |part|
  p_a_borrar =  PoliticalParty.find(part)
  p_a_borrar.destroy
  VotesTotal.destroy_all(:political_party_id => part)
end