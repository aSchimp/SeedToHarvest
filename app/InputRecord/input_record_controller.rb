require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'helpers/dateTimeHelper'

class InputRecordController < Rho::RhoController
  include BrowserHelper
  include DateTimeHelper

  # GET /InputRecord/showByPlantingRecordId/{plantingRecordId}
  def showByPlantingRecordId
    @plantingRecordId = @params['id']
      
    case @@currentlySelectedCropType
    when 0
      @inputrecords = InputRecord.find(:all,
                                     :conditions => {
                                       {
                                         :name => "PlantingRecordId",
                                         :op => "LIKE"
                                       } => @plantingRecordId
                                     },
                                     :order => ["InputDate", "InputDescription"]
                                     )
                                     
      # Get eariler input records (before the item was transplanted)
      @earlierInputRecords = []
      #
      plantingRecord = PlantingRecord.find(:first, :conditions => {{:name => "PlantingRecordId", :op => "LIKE"} => @plantingRecordId})
      @plantingRecordType = plantingRecord.PlantingType
      while(plantingRecord.ParentRecordId > -1)
        @earlierInputRecords.concat(InputRecord.find(:all, :conditions => {{:name => "PlantingRecordId", :op => "LIKE"} => plantingRecord.ParentRecordId}))
        plantingRecord = PlantingRecord.find(:first, :conditions => {{:name => "PlantingRecordId", :op => "LIKE"} => plantingRecord.ParentRecordId})
      end
    when 1,2
      @inputrecords = InputRecord.find(:all,
                                     :conditions => {
                                       {
                                         :name => "PlantingRecordId",
                                         :op => "LIKE"
                                       } => @plantingRecordId
                                     }
                                     )
                                     
      selSeasonYear = $memoryData.AppSettings.selectedSeasonYear
      recordsToDelete = []                               
      @inputrecords.each do |record|
        if Time.parse(record.InputDate).year != selSeasonYear
          recordsToDelete.push(record)
        end
      end
      # Delete after going through the loop, otherwise it will mess everything up
      recordsToDelete.each do |r|
        @inputrecords.delete(r)
      end
                                     
      # Get eariler input records (before the item was transplanted)
      @earlierInputRecords = []
      #
      plantingRecord = PlantingRecord.find(:first, :conditions => {{:name => "PlantingRecordId", :op => "LIKE"} => @plantingRecordId})
      @plantingRecordType = plantingRecord.PlantingType
      while(plantingRecord.ParentRecordId > -1)
        @earlierInputRecords.concat(InputRecord.find(:all, :conditions => {{:name => "PlantingRecordId", :op => "LIKE"} => plantingRecord.ParentRecordId}))
        plantingRecord = PlantingRecord.find(:first, :conditions => {{:name => "PlantingRecordId", :op => "LIKE"} => plantingRecord.ParentRecordId})
      end
      recordsToDelete = []
      @earlierInputRecords.each do |eRecord|
        if Time.parse(eRecord.InputDate).year != selSeasonYear
          recordToDelete.push(eRecord)
        end
      end
      recordsToDelete.each do |r|
        @earlierInputRecords.delete(r)
      end
    end
          
    if @inputrecords
      render :action => :showByPlantingRecordId, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # GET /InputRecord/new/{parentPlantingRecordId}
  def new
    @inputrecord = InputRecord.new
    @inputrecord.PlantingRecordId = @params['id']
      
    self.setMinMaxDate(PlantingRecord.find(:first, :conditions => {{:name => "PlantingRecordId", :op => "LIKE"} => @params['id']}))
    initDate = Time.new()
    if ((initDate <=> @maxDate) == 1) then initDate = @maxDate end
    if ((initDate <=> @minDate) == -1) then initDate = @minDate end 
    @inputrecord.InputDate = initDate.strftime("%Y-%m-%d")
    
    # Get the input record with the highest input record id(the one that was created last)
    lastInputRecord = nil
    # Just in case the InputRecord table wasn't created yet (i.e. no input records created yet)
    begin
      lastInputRecord = InputRecord.find(:first, :order => 'InputRecordId', :orderdir => 'DESC')
    rescue
      lastInputRecord = nil
    end
    # Set the new input record id
    if lastInputRecord != nil
      @inputrecord.InputRecordId = lastInputRecord.InputRecordId + 1
    else
      @inputrecord.InputRecordId = 0
    end
      
    render :action => :new
  end

  # GET /InputRecord/edit/{inputRecordId}
  #
  #
  # Variation 2: /InputRecord/edit?id={inputRecordId}&returnPid={returnPlantingRecordId}
  # inputRecordId: the InputRecordId of the InputRecord to be edited
  # returnPlantingRecordId: Use this parameter if you want to return to a different InputRecords page, and not the default
  #                         The default is /InputRecord/showByPlantingRecordId/{ the current input's parent planting record id}
  #                         Setting this parameter will redirect to /InputRecord/showByPlantingRecordId/{returnPlantingRecordId}
  #                         when the user leaves this page
  def edit
    @inputrecord = InputRecord.find(:first, :conditions => {{:name => "InputRecordId", :op => "LIKE"} =>@params['id']})
      
    # 
    @plantingIdOfPageToReturnTo = @params['returnPid']
    if @plantingIdOfPageToReturnTo.nil?
      @plantingIdOfPageToReturnTo = @inputrecord.PlantingRecordId
    end
    
    self.setMinMaxDate(PlantingRecord.find(:first, :conditions => {{:name => "PlantingRecordId", :op => "LIKE"} => @inputrecord.PlantingRecordId}))
    
    if @inputrecord
      render :action => :edit
    else
      redirect :action => :index
    end
  end

  # POST /InputRecord/create
  def create
    # unformat the input date for database
    @params['inputrecord']['InputDate'] = Time.parse(@params['inputrecord']['InputDate'], "%b %-d, %Y")
    @inputrecord = InputRecord.create(@params['inputrecord'])
  end

  # POST /InputRecord/update/{1}
  def update
    @inputrecord = InputRecord.find(@params['id'])
      
    # unformat the input date for the database
    @params['inputrecord']['InputDate'] = Time.parse(@params['inputrecord']['InputDate'], "%b %-d, %Y")
    @inputrecord.update_attributes(@params['inputrecord']) if @inputrecord
  end

  # POST /InputRecord/{1}/delete
  def delete
    @inputrecord = InputRecord.find(@params['id'])
      
    redirectId = @params['plantingIdOfPageToReturnTo']
    if redirectId.nil?
      redirectId = @inputrecord.PlantingRecordId.to_s
    end 
    
    @inputrecord.destroy if @inputrecord
    redirect '/app/InputRecord/showByPlantingRecordId/' + redirectId
  end
  
  # Sets @minDate and @maxDate for the date-time picker based on @@currentlySelectedCropType and $memoryData.AppSettings.selectedSeasonYear
  def setMinMaxDate(plantingRecord)
    selSeasonYear = $memoryData.AppSettings.selectedSeasonYear
    case @@currentlySelectedCropType
    when 0
      @minDate = plantingRecord.PlantingDate
      @maxDate = Time.utc(selSeasonYear + 1, 6, 30)
    when 1,2
      @minDate = Time.utc(selSeasonYear, 1, 1)
      if ((@minDate <=> plantingRecord.PlantingDate) == -1) then @minDate = plantingRecord.PlantingDate end
      @maxDate = Time.utc(selSeasonYear, 12, 31)
    end
  end
  
end
