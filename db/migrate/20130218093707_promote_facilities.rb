class PromoteFacilities < ActiveRecord::Migration
  def up
    Dhis2Mapping.where(percentage_matched: 100).map(&:promote)
  end

  def down
    Dhis2Mapping.update_all(duplicate: nil)
  end
end
