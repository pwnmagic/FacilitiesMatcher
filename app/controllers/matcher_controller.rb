class MatcherController < ApplicationController
  RESULTS_PER_PAGE = 100

  def hundred_percent_matches
    @mappings = Dhis2Mapping.paginate(:page => params[:page], :per_page => RESULTS_PER_PAGE).hundred_percent
  end

  def ninenty_nine_till_eighty
    @mappings = Dhis2Mapping.paginate(:page => params[:page], :per_page => RESULTS_PER_PAGE).ninenty_nine_till_eighty
  end

  def seventy_nine_till_fifty
    @mappings = Dhis2Mapping.paginate(:page => params[:page], :per_page => RESULTS_PER_PAGE).seventy_nine_till_fifty
  end

  def below_fifty
    @mappings = Dhis2Mapping.paginate(:page => params[:page], :per_page => RESULTS_PER_PAGE).below_fifty
  end

  def by_district
    @districts = Dhis2Mapping.select(:district).uniq(:district).collect(&:district).sort
    if district = params[:district]
      @mappings = Dhis2Mapping.by_district(district, params[:page])
    end
  end

  def summary
    @summary = {
                  'Total matches'                                 => Dhis2Mapping.count,
                  'Total matches promoted'                        => Dhis2Mapping.where(:duplicate => true).count,
                  'Total matches demoted'                         => Dhis2Mapping.where(:duplicate => false).count,
                  'Total matches to be followed up'               => Dhis2Mapping.where(:followup => true).count,
                  'Total matches yet to be reviewed'              => Dhis2Mapping.where(:duplicate => nil).count,
                  'Total facilities in mTrac'                        => HealthFacility.count,
                  'Total matches marked as duplicate'             => Dhis2Mapping.to_be_followed_up.where(:mark_duplicate => true).count,
                  'Total matches marked as delete'                => Dhis2Mapping.to_be_followed_up.where(:mark_delete => true).count,
                  'Total matches marked for reprocessing'         => Dhis2Mapping.to_be_followed_up.where(:mark_reprocess => true).count,
                  'Total matches marked for to be added in DHIS2' => Dhis2Mapping.to_be_followed_up.where(:add_to_dhis2 => true).count,
                  'Total matches marked for review in DHIS2'      => Dhis2Mapping.to_be_followed_up.where(:error_in_dhis2_data => true).count
                }
  end

  def search
    @order = params[:order] || "percentage_matched"
    @type = params[:type] || "DESC"
    query = params[:query] || ''
    @mappings = Dhis2Mapping.search_by_name(query).reorder("dhis2_mapping.#{@order} #{@type}").paginate(:page => params[:page], :per_page => RESULTS_PER_PAGE)
    if @mappings.blank?
      flash.now[:error] = "No result found!"
    else
      flash.now[:success] = "#{@mappings.count} result(s) found for '#{query}'." unless params[:page]
    end
  end

  def promote
    mapping = Dhis2Mapping.find(params[:id])
    mapping.update_attributes(:mark_duplicate => false, :mark_delete => false, :mark_reprocess => false, :add_to_dhis2 => false, :error_in_dhis2_data => false)
    mapping.promote
  end

  def demote
    mapping = Dhis2Mapping.find(params[:id])
    mapping.update_attributes(:mark_duplicate => false, :mark_delete => false, :mark_reprocess => false, :add_to_dhis2 => false, :error_in_dhis2_data => false)
    mapping.demote
  end

  def followup
    Dhis2Mapping.find(params[:id]).follow_up
  end

  def mark_duplicate
    mark_facility(:mark_duplicate)
  end

  def mark_delete
    mark_facility(:mark_delete)
    mapping = Dhis2Mapping.find(params[:id])
    mapping.facility.dhis2_mappings.update_all(:mark_delete => true)
  end

  def mark_reprocess
    mark_facility(:mark_reprocess)
  end

  def add_to_dhis2
    mark_facility(:add_to_dhis2)
  end

  def error_in_dhis2_data
    mark_facility(:error_in_dhis2_data)
  end

  def comment
    mapping = Dhis2Mapping.find(params[:id])
    mapping.add_comment(params[:comment])
    head :ok
  end

  def followups
    @order = params[:order] || "percentage_matched"
    @type = params[:type] || "DESC"
    @mappings = Dhis2Mapping.to_be_followed_up.order("dhis2_mapping.#{@order} #{@type}").paginate(:page => params[:page], :per_page => RESULTS_PER_PAGE)
    if filter = params[:filter]
      if filter.to_sym == :comment
        @mappings = @mappings.joins(:comment).where(:mark_duplicate => [false, nil], :mark_delete => [false, nil], :mark_reprocess => [false, nil], :add_to_dhis2 => [false, nil], :error_in_dhis2_data => [false, nil])
      else
        @mappings = @mappings.where(params[:filter] => true)
      end
    end
  end

  def facilities
    @facilities = HealthFacility.order(:district).paginate(:page => params[:page], :per_page => RESULTS_PER_PAGE)
  end

  private
  def mark_facility(key)
    mapping = Dhis2Mapping.find(params[:id])
    mapping.update_attributes(:mark_duplicate => false, :mark_delete => false, :mark_reprocess => false, :add_to_dhis2 => false, :error_in_dhis2_data => false, :duplicate => nil)
    mapping.update_attribute(key, true)
    mapping.follow_up
    mapping.facility.dhis2_mappings.update_all(:mark_delete => false)
    head :ok
  end

end
