class CreateFacilityLastReportedDates < ActiveRecord::Migration
  def change
    create_table :facility_last_reported_dates do |t|
      t.integer :healthfacilitybase_id
      t.timestamp :date
    end
  end
end
