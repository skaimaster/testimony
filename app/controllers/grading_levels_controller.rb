

class GradingLevelsController < ApplicationController
  before_filter :login_required
  filter_access_to :all
  def index
    @batches = Batch.active
    @grading_levels = GradingLevel.default
  end

  def new
    @grading_level = GradingLevel.new
    @batch = Batch.find params[:id] if request.xhr? and params[:id]
    if @batch.present?
      @credit = @batch.gpa_enabled? || @batch.cce_enabled?
    else
      @credit = Configuration.cce_enabled? || Configuration.get_config_value('CWA')=='1' || Configuration.get_config_value('GPA')=='1'
    end
    respond_to do |format|
      format.js { render :action => 'new' }
    end
  end

  def create
    @grading_level = GradingLevel.new(params[:grading_level])
    @batch = Batch.find params[:grading_level][:batch_id] unless params[:grading_level][:batch_id].empty?
    respond_to do |format|
      if @grading_level.save
        @grading_level.batch.nil? ?
          @grading_levels = GradingLevel.default :
          @grading_levels = GradingLevel.for_batch(@grading_level.batch_id)
        #flash[:notice] = 'Grading level was successfully created.'
        format.html { redirect_to grading_level_url(@grading_level) }
        format.js { render :action => 'create' }
      else
        @error = true
        format.html { render :action => "new" }
        format.js { render :action => 'create' }
      end
    end
  end

  def edit
    @grading_level = GradingLevel.find params[:id]
    @batch = Batch.find(@grading_level.batch_id) unless @grading_level.batch_id.nil?
    if @batch.present?
      @credit = @batch.gpa_enabled? || @batch.cce_enabled?
    else
      @credit = Configuration.get_config_value('CCE')=='1' || Configuration.get_config_value('CWA')=='1' || Configuration.get_config_value('GPA')=='1'
    end
    respond_to do |format|
      format.html { }
      format.js { render :action => 'edit' }
    end
  end

  def update
    @grading_level = GradingLevel.find params[:id]
    respond_to do |format|
      if @grading_level.update_attributes(params[:grading_level])
        if @grading_level.batch.nil?
          @grading_levels = GradingLevel.default
        else
          @batch = @grading_level.batch
          @grading_levels = GradingLevel.for_batch(@grading_level.batch_id)
        end
        #flash[:notice] = 'Grading level update successfully.'
        format.html { redirect_to grading_level_url(@grading_level) }
        format.js { render :action => 'update' }
      else
        @error = true
        format.html { render :action => "new" }
        format.js { render :action => 'create' }
      end
    end
  end

  def destroy
    @grading_level = GradingLevel.find params[:id]
    @grading_level.inactivate
    unless @grading_level.batch.nil?
      @batch = @grading_level.batch
    end
  end

  def show
    @batch = nil
    if params[:batch_id] == ''
      @grading_levels = GradingLevel.default
    else
      @grading_levels = GradingLevel.for_batch(params[:batch_id])
      @batch = Batch.find params[:batch_id] unless params[:batch_id] == ''
    end
    respond_to do |format|
      format.js { render :action => 'show' }
    end
  end

end