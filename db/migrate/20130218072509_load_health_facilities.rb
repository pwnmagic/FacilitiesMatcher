class LoadHealthFacilities < ActiveRecord::Migration
  def up
    map_hash = {}
    Dhis2Mapping.uniq(:healthfacilitybase_id).each do |mapping|
      map_hash[mapping.healthfacilitybase_id] = mapping.district
    end
    map_hash.each do |healthfacilitybase_id, district|
      HealthFacility.create!(:healthfacilitybase_id => healthfacilitybase_id, :district => district)
    end
  end

  def down
    HealthFacility.delete_all
  end
end
