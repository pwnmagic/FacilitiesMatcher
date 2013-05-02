class Dhis2Mapping < ActiveRecord::Base
  self.table_name = 'dhis2_mapping'
  attr_accessible :dhis2_name, :dhis2_owner, :dhis2_uuid, :district, :duplicate, :followup, :healthfacilitybase_id, :mtrac_name, :mtrac_owner, :percentage_matched, :f_type, :mark_duplicate, :mark_delete, :mark_reprocess, :add_to_dhis2, :error_in_dhis2_data, :reprocessed, :dhis2_f_type

  scope :hundred_percent, where('percentage_matched = ?', 100).order(:mtrac_name)
  scope :ninenty_nine_till_eighty, where('percentage_matched < ? and percentage_matched > ?', 100, 79).order('percentage_matched DESC')
  scope :seventy_nine_till_fifty, where('percentage_matched < ? and percentage_matched > ?', 80, 49).order('percentage_matched DESC')
  scope :below_fifty, where('percentage_matched < ?', 50).order('percentage_matched DESC')
  scope :to_be_followed_up, where('followup = ?', true)
  default_scope includes(:facility, :comment)

  belongs_to :facility, :class_name => "HealthFacility", :foreign_key => "healthfacilitybase_id", :primary_key => "healthfacilitybase_id"
  has_one :comment

  include PgSearch
  pg_search_scope :search_by_name, :against => [:dhis2_name, :mtrac_name]


  MTRACK_TYPE_ID_REVERSE_MAP = {
                                  4 => 'HC II',
                                  6 => 'HC III',
                                  3 => 'HC IV',
                                  5 => 'General Hospital',
                                  2 => 'DHO',
                                  1 => 'Ministry'
                                }


  def type_in_full
    MTRACK_TYPE_ID_REVERSE_MAP[self.f_type]
  end

  def promote
    Dhis2Mapping.where(healthfacilitybase_id: self.healthfacilitybase_id).update_all(duplicate: false)
    Dhis2Mapping.where(dhis2_uuid: self.dhis2_uuid).update_all(duplicate: false)
    self.duplicate = true
    self.followup = false
    self.save!
    self.facility.update_attribute(:promoted, true)
  end

  def demote
    self.facility.update_attribute(:promoted, false) if self.duplicate
    self.duplicate = false
    self.followup = false
    self.save!
  end

  def follow_up
    self.followup = true
    self.duplicate = nil
    self.facility.update_attribute(:promoted, false) if self.facility
    self.save!
  end

  def last_reported_date
    facility.last_reported_date
  end

  def show_comment
    self.comment.try(:text)
  end

  def add_comment(text)
    self.comment || self.build_comment
    self.comment.text = text
    self.comment.save!
    self.comment.delete if text.blank?
  end

  def self.by_district(district, page = nil)
    HealthFacility.where(district: district).order(:name).paginate(:page => page, :per_page => 10)
  end
end
