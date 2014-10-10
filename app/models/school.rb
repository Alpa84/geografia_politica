class School < ActiveRecord::Base

  has_many :votes_totals
  
  validates_uniqueness_of :name
  validates_presence_of :name,:address,:lat,:lon
end
