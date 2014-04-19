class AddColumnGroupToSchool < ActiveRecord::Migration
  def change
    add_column :schools, :group, :string
  end
end
