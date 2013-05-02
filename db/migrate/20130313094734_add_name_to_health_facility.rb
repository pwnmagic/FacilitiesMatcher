class AddNameToHealthFacility < ActiveRecord::Migration
  def change
    add_column :health_facilities, :name, :string
  end
end
