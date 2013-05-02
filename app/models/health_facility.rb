class HealthFacility < ActiveRecord::Base
  attr_accessible :district, :healthfacilitybase_id, :promoted, :name
  has_many :dhis2_mappings, :class_name => "Dhis2Mapping", :foreign_key => "healthfacilitybase_id", :primary_key => "healthfacilitybase_id"
  has_one :reported_date, :class_name => "FacilityLastReportedDate", :foreign_key => "healthfacilitybase_id", :primary_key => "healthfacilitybase_id"

  default_scope includes(:reported_date)

  def f_type
    dhis2_mappings.first.f_type
  end

  def owner
    dhis2_mappings.first.mtrac_owner
  end

  def facilities
    dhis2_mappings.order('percentage_matched DESC')
  end

  def last_reported_date
    reported_date.try(:date).try(:strftime, "%d %b %Y")
  end

  def self.no_of_facities_left_by_district(district)
    where(district: district, promoted: false).count
  end
end
