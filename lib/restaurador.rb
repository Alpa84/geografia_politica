

file = File::open( "vendor/assets/resultados_yaml.txt", "r" ) 
string  = file.read
restaurado = YAML.load string

no_estan_en_la_original = []

hasta_restaurado = 245-1

ides_escue =School.all.collect do |escue|
  escue.id
end

repetidas = []
restaurado.each_with_index do |local, index|
  escuela_coincidente = School.where(name:local[0][2])
  si_esta_en_la_original = escuela_coincidente.count
  if si_esta_en_la_original == 0
    p escuela_coincidente
    no_estan_en_la_original.push name:local[0]
  else
    repet = ides_escue.delete escuela_coincidente[0].id
    if repet.nil?
      repetidas.push [escuela_coincidente, local[0][2]]
    end

  end
end


estan_en_la_original_y_no_en_la_restaurada = []
todas_originales = School.all
todas_restauradas = restaurado.collect do |esc_rest|
  esc_rest[0][2]
end

todas_originales.each do |esc_original|
  unless todas_restauradas.include? esc_original.name
    estan_en_la_original_y_no_en_la_restaurada.push  esc_original.name
  end
end




está_en_restaurada_y_no_en_original = [{:name=>[4176..4186, "RAZORI 3518", "ESC.N°1226 GESTA DE MAYO-RAZORI 3518"]}]
estan_en_la_original_y_no_en_la_restaurada = []

cant_restaurado = 245
cant_schools = 242


#hay dos repetidas??
repetidas = [["School", "E.E.M.N°430 D.F.SARMIENTO-9 DE JULIO   80"], ["School", "CENTRO DE LA JUVENTUD-AV.BELGRANO  950"]]


binding.pry