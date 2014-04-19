class School < ActiveRecord::Base

  has_many :votes_totals
  
  validates_uniqueness_of :name
  validates_presence_of :name
  validates_presence_of :address
  validates_presence_of :lat
  validates_presence_of :lon

end
