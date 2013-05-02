class AddColumnDuplicateDeletedReprocessToDhis2Mapping < ActiveRecord::Migration
  def change
    add_column :dhis2_mapping, :mark_duplicate, :boolean, :default => false
    add_column :dhis2_mapping, :mark_delete, :boolean, :default => false
    add_column :dhis2_mapping, :mark_reprocess, :boolean, :default => false
  end
end