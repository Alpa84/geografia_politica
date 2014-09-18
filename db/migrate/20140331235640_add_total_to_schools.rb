class AddTotalToSchools < ActiveRecord::Migration
  def change
    add_column :schools, :total, :integer
  end
end
