require 'spec_helper'

describe HealthFacility do
  it 'should return me the name' do
    dhis2_mapping = Dhis2Mapping.create(healthfacilitybase_id: 1, district: 'a', f_type: 'HC ii', mtrac_owner: 'GOVT')
    health_facility = HealthFacility.create!(healthfacilitybase_id: 1, district: 'a', name: 'Rajini')
    health_facility.name.should == 'Rajini'
    health_facility.f_type.should == 'HC ii'
    health_facility.owner.should == 'GOVT'
    health_facility.facilities.should == [dhis2_mapping]
  end

  it "should return the number of facilities yet to be promoted per district" do
    health_facility = HealthFacility.create!(healthfacilitybase_id: 1, district: 'a', promoted: true)
    health_facility_1 = HealthFacility.create!(healthfacilitybase_id: 2, district: 'a')
    health_facility_2 = HealthFacility.create!(healthfacilitybase_id: 3, district: 'a')

    health_facility_3 = HealthFacility.create!(healthfacilitybase_id: 1, district: 'b', promoted: true)
    HealthFacility.no_of_facities_left_by_district('a').should == 2
    HealthFacility.no_of_facities_left_by_district('b').should == 0

    health_facility_4 = HealthFacility.create!(healthfacilitybase_id: 1, district: 'c', promoted: false)
    HealthFacility.no_of_facities_left_by_district('c').should == 1
  end

  it "should return me the last reported date" do
    health_facility = HealthFacility.create!(healthfacilitybase_id: 1, district: 'a', promoted: true)
    date = 1.day.ago
    last_reported_date = FacilityLastReportedDate.create!(healthfacilitybase_id: 1, date: date)
    health_facility.last_reported_date.should == date.strftime("%d %b %Y")
  end

  it "should return nil if the last reported date is not available" do
    health_facility = HealthFacility.create!(healthfacilitybase_id: 1, district: 'a', promoted: true)
    health_facility.last_reported_date.should be_nil
  end
end
