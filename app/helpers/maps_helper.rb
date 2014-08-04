module MapsHelper

  def labels( min_max, labels_divisions = 5)
    increment = ((min_max[:max] - min_max[:min] ).to_f / (labels_divisions - 1 ) )
    labels_values = labels_divisions.times.collect do |time|
      label_value = (min_max[:max] - (increment * time))
      (min_max[:max] - min_max[:min]) < 0.06 ? decimals = 2: decimals = 0
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
        part[0] = [part[0], ' (Part. Socialista)'].join
      when 3
        part[0] = [part[0], ' (Kirchnerismo)'].join
      when 2
        part[0] = [part[0], ' (PRO)'].join
      end
    end
  end

end