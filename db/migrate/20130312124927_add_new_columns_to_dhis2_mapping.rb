class AddNewColumnsToDhis2Mapping < ActiveRecord::Migration
  def change
    add_column :dhis2_mapping, :add_to_dhis2, :boolean, :default => false
    add_column :dhis2_mapping, :error_in_dhis2_data, :boolean, :default => false
  end
end
