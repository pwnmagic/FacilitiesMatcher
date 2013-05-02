class AddAlreadyMatchedColumnToDhis2Mapping < ActiveRecord::Migration
  def change
    add_column :dhis2_mapping, :already_matched, :boolean, :default => false
  end
end