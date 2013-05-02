class FixFollowupDuplicateIssue < ActiveRecord::Migration
  def up
    Dhis2Mapping.where(:followup => true, :duplicate => [true, false]).map(&:follow_up)
  end

  def down
  end
end
