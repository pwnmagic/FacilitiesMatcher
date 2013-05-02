class AddReprocessedFieldToDhis2Mapping < ActiveRecord::Migration
  def change
    add_column :dhis2_mapping, :reprocessed, :boolean
    add_column :dhis2_mapping, :dhis2_f_type, :string
  end
end