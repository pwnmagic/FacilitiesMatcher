class PopulateNameToHealthFacility < ActiveRecord::Migration
  def up
    HealthFacility.all.each do |hf|
      hf.name = hf.dhis2_mappings.first.mtrac_name
      hf.save!
    end
  end

  def down
  end
end
