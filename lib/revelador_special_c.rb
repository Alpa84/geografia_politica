special_c= []
School.all.each do |school|
  match = school.name.scan(/\W/)
  match.each  {|mat| special_c.concat match unless special_c.include? mat }
end
special_c = '"  - . °  .- ...° .-ø   .° .. Ñ-  . \'  - . °-  (ø)"'