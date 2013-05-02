class AddNewFieldFacilities < ActiveRecord::Migration
  def up
    add_column :health_facilities, :promoted, :boolean, :default => false
  end

  def down
    remove_column :health_facilities, :promoted
  end
end