class VotesTotal < ActiveRecord::Base
  belongs_to :school
  belongs_to :political_party
  belongs_to :public_office
end
