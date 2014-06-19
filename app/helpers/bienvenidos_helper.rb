module BienvenidosHelper
  def labels( min_max, labels_divisions = 5)
    increment = ((min_max[:max] - min_max[:min] ).to_f / (labels_divisions - 1 ) )
    labels_values = labels_divisions.times.collect do |time|
      label_value = (min_max[:max] - (increment * time))
      (min_max[:max] - min_max[:min]) < 0.06 ? decimals = 2: decimals = 0
      label_percentage = (label_value * 100).round(decimals).to_s
      '<p>' + label_percentage + '%' + '</p>'+ "<p class='lab#{time} labels'> ● "
    end.join('<br>').html_safe
  end
end
