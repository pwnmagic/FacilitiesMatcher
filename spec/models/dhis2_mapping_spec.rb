require 'spec_helper'

describe Dhis2Mapping do
  it "should return me all the records with 100% match" do
    Dhis2Mapping.hundred_percent.where_values.should == ["percentage_matched = 100"]
    Dhis2Mapping.hundred_percent.order_values.should == [:mtrac_name]
  end

  it "should return me all the records between 99% till 80% match" do
    Dhis2Mapping.ninenty_nine_till_eighty.where_values.should == ['percentage_matched < 100 and percentage_matched > 79']
    Dhis2Mapping.ninenty_nine_till_eighty.order_values.should == ['percentage_matched DESC']
  end

  it "should return me all the records between 79% till 50% match" do
    Dhis2Mapping.seventy_nine_till_fifty.where_values.should == ['percentage_matched < 80 and percentage_matched > 49']
    Dhis2Mapping.seventy_nine_till_fifty.order_values.should == ['percentage_matched DESC']
  end

  it "should return me all the records below 50% match" do
    Dhis2Mapping.below_fifty.where_values.should == ["percentage_matched < 50"]
    Dhis2Mapping.below_fifty.order_values.should == ['percentage_matched DESC']
  end

  it "should return ma all the records marked for follow_up" do
    Dhis2Mapping.to_be_followed_up.where_values.should == ["followup = 't'"]
    Dhis2Mapping.to_be_followed_up.order_values.should == []
  end

  it "should return me the facility types in text" do
    map = {
            '4' => 'HC II',
            '6' => 'HC III',
            '3' => 'HC IV',
            '5' => 'General Hospital',
            '2' => 'DHO',
            '1' => 'Ministry'
          }
    map.each do |key, value|
      Dhis2Mapping.new(f_type: key).type_in_full == value
    end
  end

  context :Promote do
    it "should promote a match and demote all related matches" do
      mtrac_id = 1
      dhis_id = 'dhis_id1'

      Dhis2Mapping.create(healthfacilitybase_id: mtrac_id)
      Dhis2Mapping.create(healthfacilitybase_id: mtrac_id)
      facility = Dhis2Mapping.create(healthfacilitybase_id: mtrac_id, dhis2_uuid: dhis_id)
      health_facility = HealthFacility.create!(healthfacilitybase_id: mtrac_id, district: 'some_district')
      Dhis2Mapping.create(dhis2_uuid: dhis_id)
      Dhis2Mapping.create(dhis2_uuid: dhis_id)

      Dhis2Mapping.create()
      Dhis2Mapping.create()

      Dhis2Mapping.where(duplicate: true).count.should == 0
      Dhis2Mapping.where(duplicate: false).count.should == 0
      Dhis2Mapping.where(duplicate: nil).count.should == 7

      facility.promote
      Dhis2Mapping.where(duplicate: true).count.should == 1
      Dhis2Mapping.where(duplicate: false).count.should == 4
      Dhis2Mapping.where(duplicate: nil).count.should == 2
    end

    it "should mark promoted in corresponding health facility" do
      dhis2_mapping = Dhis2Mapping.create(healthfacilitybase_id: 1, district: 'some_district', mtrac_name: 'Rajini', f_type: 'HC ii', mtrac_owner: 'GOVT')
      health_facility = HealthFacility.create!(healthfacilitybase_id: 1, district: 'some_district')
      health_facility.promoted.should == false
      dhis2_mapping.promote
      health_facility.reload
      health_facility.promoted.should == true
    end
  end

  context :Demote do
    it "should demote a facility" do
      facility = Dhis2Mapping.create()
      Dhis2Mapping.where(duplicate: false).count.should == 0
      facility.demote
      facility.duplicate.should == false
      Dhis2Mapping.where(duplicate: false).count.should == 1
    end

    it "should mark a facility as demoted when it is already marked as promoted" do
      facility = Dhis2Mapping.create(healthfacilitybase_id: 1, district: 'some_district', mtrac_name: 'Rajini', f_type: 'HC ii', mtrac_owner: 'GOVT')
      health_facility = HealthFacility.create!(healthfacilitybase_id: 1, district: 'some_district')
      health_facility.promoted = nil
      health_facility.save!

      facility.demote
      health_facility.reload
      health_facility.promoted.should be_nil

      facility.promote
      health_facility.reload
      health_facility.promoted.should be_true

      facility.demote
      health_facility.reload
      health_facility.promoted.should be_false
    end
  end

  context :follow_up do
    it "should mark follow up true" do
      facility = Dhis2Mapping.create(healthfacilitybase_id: 1, district: 'some_district', mtrac_name: 'Rajini', f_type: 'HC ii', mtrac_owner: 'GOVT')
      health_facility = HealthFacility.create!(healthfacilitybase_id: 1, district: 'some_district')

      facility.follow_up
      facility.followup.should == true
      facility.duplicate.should be_nil
      facility.facility.promoted.should be_false

      facility.promote
      facility.followup.should == false
      facility.facility.promoted.should be_true

      facility.follow_up
      facility.followup.should == true
      facility.duplicate.should be_nil
      facility.facility.promoted.should be_false

      facility.demote
      facility.followup.should == false
    end
  end

  context :search do
    it "should search agains facility names" do
      a = Dhis2Mapping.create(dhis2_name: 'dhis name')
      b = Dhis2Mapping.create(mtrac_name: 'mtrac name')

      Dhis2Mapping.search_by_name('name').should  == [a, b]
      Dhis2Mapping.search_by_name('dhis').should  == [a]
      Dhis2Mapping.search_by_name('mtrac').should == [b]
    end
  end

  context :mappings_by_facilities do
    it "should return facilities based on a district" do
      dhis2_mapping = Dhis2Mapping.create(healthfacilitybase_id: 1, district: 'some_district', mtrac_name: 'Rajini', f_type: 'HC ii', mtrac_owner: 'GOVT')
      health_facility = HealthFacility.create!(healthfacilitybase_id: 1, district: 'some_district')
      health_facility_1 = HealthFacility.create!(healthfacilitybase_id: 2, district: 'some_district')

      Dhis2Mapping.by_district('some_district').should == [health_facility, health_facility_1]
      Dhis2Mapping.by_district('some_district').should_not == [health_facility_1, health_facility]
    end
  end

  it "should return me the last reported date" do
    dhis2_mapping = Dhis2Mapping.create(healthfacilitybase_id: 1, district: 'some_district', mtrac_name: 'Rajini', f_type: 'HC ii', mtrac_owner: 'GOVT')
    health_facility = HealthFacility.create!(healthfacilitybase_id: 1, district: 'some_district')
    date = 1.day.ago
    last_reported_date = FacilityLastReportedDate.create!(healthfacilitybase_id: 1, date: date)
    dhis2_mapping.last_reported_date.should == date.strftime("%d %b %Y")
  end

  it "Should add comment" do
    dhis2_mapping = Dhis2Mapping.create
    dhis2_mapping.show_comment.should be_nil
    comment = "comment"
    dhis2_mapping.add_comment(comment)
    dhis2_mapping.reload
    dhis2_mapping.show_comment.should == comment

    dhis2_mapping.add_comment("")
    dhis2_mapping.reload
    dhis2_mapping.comment.should be_nil
  end
end