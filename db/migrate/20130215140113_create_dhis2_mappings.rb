class CreateDhis2Mappings < ActiveRecord::Migration
  def change
    create_table :dhis2_mapping do |t|
      t.string :mtrac_name
      t.string :mtrac_owner
      t.integer :healthfacilitybase_id
      t.string :dhis2_name
      t.string :dhis2_owner
      t.string :dhis2_uuid
      t.string :district
      t.string :f_type
      t.float :percentage_matched
      t.boolean :duplicate
      t.boolean :followup
    end
  end
end
