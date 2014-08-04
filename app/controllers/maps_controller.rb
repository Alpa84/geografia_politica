class MapsController < ApplicationController

  def index
    if params['partido'].blank? 
      @party_id = 65
    else
      @party_id = params['partido']['political_party_id']
      @public_office_id = params['cargo']['public_office_id']
    end
    
    @all_circles = Circles.circles_and_labels({'public_office_id' => @public_office_id, 'party_id' => @party_id})

    @pro_circles = Circles.circles_and_labels({'party_id' => 2})

    @socialismo_circles = Circles.circles_and_labels({'party_id' => 4})

    @k_circles = Circles.circles_and_labels({'party_id' => 3})

    @castells_circles = Circles.circles_and_labels({'public_office_id' => 1, 'party_id' => 5}, true)

  end

end
#something happens when checking a party with no candidate, then checking  default values again, in remote false
# check unused js and other files
# check ajax is working
# if turbolink if doing all the stuff, why the partial?
# why does it runs all queries again?  should it be outside the index method?

# rename variables for better reading
#rename controller name
# FORK LEAFLET GEM
# CHECK OOP Principles
# GET rid of unused js 
# MAKE TESTS
# check other issues
