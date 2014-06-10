require 'uri'

class BienvenidosController < ApplicationController

LOW_COLOR  = 0x000000 
HIGH__COLOR = 0xFF7700
SAMPLES = 100
LEGEND_SAMPLES = 5
  def index
    @fillOpacity = 1
    @radius = 400
    @public_offices = PublicOffice.all
    @public_offices_plus_one = @public_offices.order(:name).collect {|p| [ p.name.humanize, p.id ]} + [['Todos los Cargos', 't'] ]
    @partidos_drop = PoliticalParty.all.order(:name).collect {|p| [ p.name.humanize, p.id ]}
    # HHARCODED BUT FINE?
    @partidos_drop.each do |part|
      case part[1]
      when 4
        part[0] = [part[0], ' (Part. Socialista)'].join
      when 3
        part[0] = [part[0], ' (Kirchnerismo)'].join
      when 2
        part[0] = [part[0], ' (PRO)'].join
      end
    end

  
    @legend_samples = LEGEND_SAMPLES
    if params['partido'].blank? 
      @party_id = 66
      @public_office_id = 2
    else
      @party_id = params['partido']['political_party_id']
      @public_office_id = params['partido']['public_office_id']
    end
    # TODO: MERGE HASHES
    @gradient = Gradient.new( LOW_COLOR, HIGH__COLOR, SAMPLES)
    
    @all_circles = circulos_de_intensidad({'public_office_id' => @public_office_id, 'party_id' => @party_id})

    @fein_circles = circulos_de_intensidad({'public_office_id' => 4, 'party_id' => 4})

    @miguel_circles = circulos_de_intensidad({'public_office_id' => 2, 'party_id' => 4})

    @castells_circles = circulos_de_intensidad({'public_office_id' => 1, 'party_id' => 5})

    @pro_circles = circulos_de_intensidad({'party_id' => 2})

    @socialismo_circles = circulos_de_intensidad({'party_id' => 4})

    @k_circles = circulos_de_intensidad({'party_id' => 3})

  end
end
# TODO: put in a class or into a model?
def circulos_de_intensidad(selected = {'party_id' => 1})
    circles = {}
    max = nil
    min = nil
  if selected['public_office_id'] and selected['public_office_id'] != 't'
    votes_schools = VotesTotal.votes_per_school(selected)
    max = votes_schools.map {|votes_school| votes_school.votes / votes_school.school.total.to_f}.max
    min = votes_schools.map {|votes_school| votes_school.votes / votes_school.school.total.to_f}.min
    votes_range = max - min

    leaflet_without_interpolation = votes_schools.collect do |vote_school|
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
  else
    parties_partials = VotesTotal.party_totals_per_school(selected)
    max = parties_partials.map {|partial| partial[1]}.max
    min = parties_partials.map {|partial| partial[1]}.min
    votes_range = max - min 
    schools = School.all
    leaflet_without_interpolation = schools.collect do |school|
      votes = parties_partials[school.id]
      total = school.total * @public_offices.count
      lat = school.lat
      lon = school.lon
      ratio = (votes.to_f / total)
      intensity = (ratio - min ) * 100 / votes_range
      color = "#" + @gradient.gradient(intensity).to_s(16)
      school_name = School.name
      popup = "<b>#{(ratio*100).round(2)}%</b> de este local electoral, <br><b>#{votes}</b> votos de un total de <b>#{total}</b>, <br>#{school.name} ".gsub(/[°()\'\"]/i, '') 
      circles = {:ratio => ratio, :latlng => [lon, lat], :popup => popup, :radius => @radius, :fillOpacity  => @fillOpacity, :color => color, :fillColor => color}
    end  
  end
  { :leaflet => leaflet_without_interpolation, :labels => {:min => min, :max => max} }
end


# FORK LEAFLET GEM
# CHECK OOP Principles
# GET rid of unused js 
# MAKE TESTS

# module LabelsHelper
#   @lab_arr = []
#   def map_labels ( min_max)
#     increment = ((min_max[:max] - min_max[:min] ).to_f / (@legend_samples -1  ) )
#     @legend_samples.times do |time|
#       @lab_arr.push (min_max[:max] - (increment * time))
#     end
#     build_html_labels(lab_arr)
#   end

#   def build_html_labels(labels_numbers)
#     @legend_samples.times do |time|
#       (@k_circles[:labels][time] * 100 ).round.to_s+"%"
#       %p{:class => ["lab#{time.to_s}", 'labels' ] } ●
#   end
# end