class School < ActiveRecord::Base

  has_many :votes_totals
  
  # fijate si los mismos tipos de validaciones se pueden poner en la misma linea
  validates_uniqueness_of :name
  validates_presence_of :name
  validates_presence_of :address
  validates_presence_of :lat
  validates_presence_of :lon

end
