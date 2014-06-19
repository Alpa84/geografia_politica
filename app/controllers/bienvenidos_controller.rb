class BienvenidosController < ApplicationController

  def index
    @public_offices_plus_one = PublicOffice.all.order(:name).collect {|p| [ p.name.humanize, p.id ]} + [['Todos los Cargos', 0] ]
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
  
    if params['partido'].blank? 
      @party_id = 65
    else
      @party_id = params['partido']['political_party_id']
      @public_office_id = params['partido']['public_office_id']
    end
    
    @all_circles = Circles.circles_and_labels({'public_office_id' => @public_office_id, 'party_id' => @party_id})

    #@fein_circles = Circles.circles_and_labels({'public_office_id' => 4, 'party_id' => 4})

    #@miguel_circles = Circles.circles_and_labels({'public_office_id' => 2, 'party_id' => 4})

    @pro_circles = Circles.circles_and_labels({'party_id' => 2})

    @socialismo_circles = Circles.circles_and_labels({'party_id' => 4})

    @k_circles = Circles.circles_and_labels({'party_id' => 3})

    @castells_circles = Circles.circles_and_labels({'public_office_id' => 1, 'party_id' => 5}, true)

  end
end

# raname variables for better reading
# FORK LEAFLET GEM
# CHECK OOP Principles
# GET rid of unused js 
# MAKE TESTS

