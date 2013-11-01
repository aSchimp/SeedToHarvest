require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'helpers/dateTimeHelper'

class MiscRecordController < Rho::RhoController
  include BrowserHelper
  include DateTimeHelper

  # GET /MiscRecord/showByPlantingRecordId/{plantingRecordId}
  def showByPlantingRecordId
    @plantingRecordId = @params['id']
    @miscrecords = MiscRecord.find(:all, :conditions => {{:name => "PlantingRecordId", :op => "LIKE"} => @plantingRecordId}, :order => ["Date", "Description"])
    # For biennial and perennial crop types
    if(@@currentlySelectedCropType == 1 || @@currentlySelectedCropType == 2)
      selSeasonYear = $memoryData.AppSettings.selectedSeasonYear
      recordsToDelete = []
      @miscrecords.each do |record|
        if Time.parse(record.Date).year != selSeasonYear
          recordsToDelete.push(record)
        end
      end
      recordsToDelete.each do |r|
        @miscrecords.delete(r)
      end
    end
    
    if @miscrecords
      render :action => :showByPlantingRecordId
    else
      redirect :action => :index
    end
  end

  # GET /MiscRecord/new/{parentPlantingRecordId}
  def new
    @miscrecord = MiscRecord.new
    @miscrecord.PlantingRecordId = @params['id']
      
    self.setMinMaxDate(PlantingRecord.find(:first, :conditions => {{:name => "PlantingRecordId", :op => "LIKE"} => @params['id']}))
    initDate = Time.new()
    if ((initDate <=> @maxDate) == 1) then initDate = @maxDate end
    if ((initDate <=> @minDate) == -1) then initDate = @minDate end 
    @miscrecord.Date = initDate.strftime("%Y-%m-%d")
    
    # Get the misc record with the highest misc record id(the one that was created last)
    lastMiscRecord = nil
    # Just in case the MiscRecord table wasn't created yet (i.e. no misc records created yet)
    begin
      lastMiscRecord = MiscRecord.find(:first, :order => 'MiscRecordId', :orderdir => 'DESC')
    rescue
      lastMiscRecord = nil
    end
    # Set the new misc record id
    if lastMiscRecord != nil
      @miscrecord.MiscRecordId = lastMiscRecord.MiscRecordId + 1
    else
      @miscrecord.MiscRecordId = 0
    end
      
    render :action => :new
  end

  # GET /MiscRecord/edit/{MiscRecordId}
   def edit
     @miscrecord = MiscRecord.find(:first, :conditions => {{:name => "MiscRecordId", :op => "LIKE"} => @params['id']})
          
     self.setMinMaxDate(PlantingRecord.find(:first, :conditions => {{:name => "PlantingRecordId", :op => "LIKE"} => @miscrecord.PlantingRecordId}))
     if @miscrecord
       render :action => :edit
     else
       redirect :action => :index
     end
   end

  # POST /MiscRecord/create
  def create
    # unformat the misc record date for database
    @params['miscrecord']['Date'] = Time.parse(@params['miscrecord']['Date'], "%b %-d, %Y")
    @miscrecord = MiscRecord.create(@params['miscrecord'])
  end

  # POST /MiscRecord/{1}/update
  def update
    # unformat the misc date for database
    @params['miscrecord']['Date'] = Time.parse(@params['miscrecord']['Date'], "%b %-d, %Y")
    
    @miscrecord = MiscRecord.find(@params['id'])
    @miscrecord.update_attributes(@params['miscrecord']) if @miscrecord
  end

  # POST /MiscRecord/{1}/delete
  def delete
    @miscrecord = MiscRecord.find(@params['id'])
    plantingRecordId = @miscrecord.PlantingRecordId
    @miscrecord.destroy if @miscrecord
    redirect '/app/MiscRecord/showByPlantingRecordId/' + plantingRecordId.to_s
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
