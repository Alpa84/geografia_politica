class MapsController < ApplicationController

  DEFAULT_PARTY_ID = 65
  def index

    if params['partido'].blank?
      @party_id = DEFAULT_PARTY_ID
    else
      @party_id = params['partido']['political_party_id']
      @public_office_id = params['cargo']['public_office_id']
    end
    
    @requested_circles = CircleGroup.new({'public_office_id' => @public_office_id, 'party_id' => @party_id})

  end

end

# MAKE TESTS
