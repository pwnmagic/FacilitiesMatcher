require 'spec_helper'

describe MatcherController do

  before(:each) do
    user = 'matcher'
    pw = 'R@j1n1'
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user,pw)
  end

  describe "GET 'hundred_percent_matches'" do
    it "returns http success" do
      mapping = Dhis2Mapping.create(percentage_matched: 90)
      mapping = Dhis2Mapping.create(percentage_matched: 100)
      get 'hundred_percent_matches'
      response.should be_success
      assigns[:mappings].should == [mapping]
    end
  end

  describe "GET 'ninenty_nine_till_eighty'" do
    it "returns http success" do
      mapping = Dhis2Mapping.create(percentage_matched: 100)
      mapping = Dhis2Mapping.create(percentage_matched: 90)
      get 'ninenty_nine_till_eighty'
      response.should be_success
      assigns[:mappings].should == [mapping]
    end
  end

  describe "GET 'seventy_nine_till_fifty'" do
    it "returns http success" do
      mapping = Dhis2Mapping.create(percentage_matched: 90)
      mapping = Dhis2Mapping.create(percentage_matched: 70)
      get 'seventy_nine_till_fifty'
      response.should be_success
      assigns[:mappings].should == [mapping]
    end
  end

  describe "GET 'below_fifty'" do
    it "returns http success" do
      mapping = Dhis2Mapping.create(percentage_matched: 70)
      mapping = Dhis2Mapping.create(percentage_matched: 30)
      get 'below_fifty'
      response.should be_success
      assigns[:mappings].should == [mapping]
    end
  end

  describe "GET 'by_district'" do
    it "returns http success" do
      mapping = Dhis2Mapping.create(district: 'some district')
      get 'by_district'
      response.should be_success
      assigns[:districts].should == ['some district']
      assigns[:mappings].should == nil
    end

    it 'returns the facilities in a particular district when a district is passed in query' do
      dhis2_mapping = Dhis2Mapping.create(healthfacilitybase_id: 1, district: 'some_district', mtrac_name: 'Rajini', f_type: 'HC ii', mtrac_owner: 'GOVT')
      health_facility = HealthFacility.create!(healthfacilitybase_id: 1, district: 'some_district')

      get 'by_district', district: 'some_district'
      response.should be_success
      assigns[:districts].should == ['some_district']
      assigns[:mappings].should == [health_facility]
    end
  end

  describe "GET 'summary'" do
    it "returns http success" do
      get 'summary'
      response.should be_success
      assigns[:summary].should == {
        'Total matches'                    => 0,
        'Total matches promoted'           => 0,
        'Total matches demoted'            => 0,
        'Total matches to be followed up' => 0,
        'Total matches yet to be reviewed' => 0,
        'Total facilities in mTrac'          => 0,
        'Total matches marked as duplicate' => 0,
        'Total matches marked as delete' => 0,
        'Total matches marked for reprocessing' => 0,
        'Total matches marked for to be added in DHIS2' => 0,
        'Total matches marked for review in DHIS2' => 0
      }
    end
  end

  describe "GET 'search'" do
    it "returns http success" do
      a = Dhis2Mapping.create(dhis2_name: 'dhis name')
      get 'search', query: 'dhis'
      response.should be_success
      assigns[:mappings].should == [a]
      flash.now[:success].should == "1 result(s) found for 'dhis'."

      get 'search', query: 'asdsa'
      response.should be_success
      assigns[:mappings].should == []
      flash.now[:error].should == 'No result found!'
    end

    ["district","percentage_matched", "mtrac_name", "dhis2_name"].each do |criteria|
      it "returns the records in order of #{criteria}" do
        dhis2_mappings = []
        10.times {
          |i| dhis2_mappings << Dhis2Mapping.create(percentage_matched:(90+i), district:"District#{i}", mtrac_name: "Mtrac name #{i}", dhis2_name: "DHIS name #{i}")
        }
        get 'search', query: "name", order: criteria, type: "ASC"
        response.should be_success
        assigns[:mappings].should == dhis2_mappings

        get 'search', query: "name", order: criteria, type: "DESC"
        response.should be_success
        assigns[:mappings].should == dhis2_mappings.reverse
      end
    end
  end

  describe "get 'promote'" do
    it "returns http success" do
      a = Dhis2Mapping.create(healthfacilitybase_id: 1, district: 'some_district', mtrac_name: 'Rajini', f_type: 'HC ii', mtrac_owner: 'GOVT')
      a.update_attributes(:mark_duplicate => true, :mark_delete => true, :mark_reprocess => true, :add_to_dhis2 => true, :error_in_dhis2_data => true)
      health_facility = HealthFacility.create!(healthfacilitybase_id: 1, district: 'some_district')
      a.duplicate.should == nil
      get 'promote', id: a.id
      response.should be_success
      a.reload
      a.duplicate.should == true
      [:mark_duplicate, :mark_delete, :mark_reprocess, :add_to_dhis2, :error_in_dhis2_data].each do |method|
        a.send(method).should be_false
      end
    end
  end

  describe "get 'demote'" do
    it "returns http success" do
      a = Dhis2Mapping.create()
      a.update_attributes(:mark_duplicate => true, :mark_delete => true, :mark_reprocess => true, :add_to_dhis2 => true, :error_in_dhis2_data => true)
      a.duplicate.should == nil
      get 'demote', id: a.id
      response.should be_success
      a.reload
      a.duplicate.should == false
      [:mark_duplicate, :mark_delete, :mark_reprocess, :add_to_dhis2, :error_in_dhis2_data].each do |method|
        a.send(method).should be_false
      end
    end
  end

  describe "get 'followup'" do
    it "returns http success" do
      a = Dhis2Mapping.create()
      a.followup.should == nil
      get 'followup', id: a.id
      response.should be_success
      a.reload
      a.followup.should == true
    end
  end

  describe "get followups" do
    it "returns all the records marked as followup" do
      a = Dhis2Mapping.create()
      a.follow_up
      get 'followups'
      response.should be_success
      assigns[:mappings].should == [a]
    end

    [:mark_duplicate, :mark_delete, :mark_reprocess, :add_to_dhis2, :error_in_dhis2_data, :comment].each do |criteria|
      it "returns all the filtered records marked as followup" do
        followups = {
          :mark_duplicate => Dhis2Mapping.create(:followup => true, :mark_duplicate => true),
          :mark_delete => Dhis2Mapping.create(:followup => true, :mark_delete => true),
          :mark_reprocess => Dhis2Mapping.create(:followup => true, :mark_reprocess => true),
          :add_to_dhis2 => Dhis2Mapping.create(:followup => true, :add_to_dhis2 => true),
          :error_in_dhis2_data => Dhis2Mapping.create(:followup => true, :error_in_dhis2_data => true),
          :comment => Dhis2Mapping.create(:followup => true)
        }
        followups[:comment].add_comment("comment")
        Dhis2Mapping.create(:followup => true).add_comment("")
        get 'followups', filter: criteria
        response.should be_success
        assigns[:mappings].should == [followups[criteria]]
      end
    end


    ["district","percentage_matched", "mtrac_name", "dhis2_name"].each do |criteria|
      it "returns the records in order of #{criteria}" do
        followups = []
        10.times {
          |i| followups << Dhis2Mapping.create(percentage_matched:(90+i), district:"District#{i}", mtrac_name: "Mtrac name #{i}", dhis2_name: "DHIS name #{i}")
          followups[i].follow_up
        }
        get 'followups', order: criteria, type: "ASC"
        response.should be_success
        assigns[:mappings].should == followups

        get 'followups', order: criteria, type: "DESC"
        response.should be_success
        assigns[:mappings].should == followups.reverse
      end
    end
  end

  describe "get facilities summary" do
    it "returns all the facilities" do
      health_facility = HealthFacility.create!(healthfacilitybase_id: 1, district: 'some_district')
      get 'facilities'
      response.should be_success
      assigns[:facilities].should == [health_facility]
    end
  end

  [:mark_duplicate, :mark_delete, :mark_reprocess, :add_to_dhis2, :error_in_dhis2_data].each do |method|
    describe method do
      it "should #{method}" do
        a = Dhis2Mapping.create(:duplicate => true, :followup => true)
        a.facility = HealthFacility.create!(healthfacilitybase_id: 1, district: 'some_district')
        a.save!
        a.facility.dhis2_mappings.create()
        a.facility.dhis2_mappings.count.should == 2
        a.send(method).should be_false
        get method, id: a.id
        response.should be_success
        a.reload
        a.send(method).should be_true
        a.duplicate.should be_nil
        a.followup.should be_true
        a.facility.dhis2_mappings.collect(&:mark_delete).uniq.should == [method == :mark_delete]
        ([:mark_duplicate, :mark_delete, :mark_reprocess, :add_to_dhis2, :error_in_dhis2_data] - [method]).each do |method|
          a.send(method).should be_false
        end
      end

      it "should automatically marked for followup" do
        a = Dhis2Mapping.create()
        a.facility = HealthFacility.create!(healthfacilitybase_id: 1, district: 'some_district')
        a.save!
        get method, id: a.id
        a.reload
        a.send(method).should be_true
        a.followup.should be_true
      end
    end
  end

  describe "mark_delete" do
    it "should mark all the related facilities as delete as well" do
      health_facility = HealthFacility.create!(healthfacilitybase_id: 1, district: 'some_district')
      2.times{
        health_facility.dhis2_mappings.build()
        health_facility.save!
      }
      health_facility.dhis2_mappings.count.should == 2
      health_facility.dhis2_mappings.collect(&:mark_delete).uniq.should == [false]

      mapping = health_facility.dhis2_mappings.first
      get :mark_delete, id: mapping.id
      mapping.reload
      mapping.mark_delete.should be_true
      health_facility.reload
      health_facility.dhis2_mappings.collect(&:mark_delete).uniq.should == [true]
    end
  end


  describe "Comment" do
    it "should add comment" do
      a = Dhis2Mapping.create()
      a.show_comment.should be_nil
      comment = "comment"
      put :comment, id: a.id, comment: comment
      response.should be_success
      a.reload
      a.show_comment.should == comment
    end
  end
end
