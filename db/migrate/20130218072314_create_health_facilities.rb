class CreateHealthFacilities < ActiveRecord::Migration
  def change
    create_table :health_facilities do |t|
      t.integer :healthfacilitybase_id
      t.string :district
    end
  end
end
