require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'helpers/dateTimeHelper'
require 'time'
require 'date'

class HarvestRecordController < Rho::RhoController
  include BrowserHelper
  include DateTimeHelper

  # GET /HarvestRecord/showByPlantingRecordId/{plantingRecordId}
  def showByPlantingRecordId
    @plantingRecordId = @params['id']
    @harvestrecords = HarvestRecord.find(:all, :conditions => {{:name => "PlantingRecordId", :op => "LIKE"} => @plantingRecordId}, :order => "HarvestDate")
    # For biennial and perennial crop types
    if(@@currentlySelectedCropType == 1 || @@currentlySelectedCropType == 2)
      selSeasonYear = $memoryData.AppSettings.selectedSeasonYear
      recordsToDelete = []
      @harvestrecords.each do |record|
        if Time.parse(record.HarvestDate).year != selSeasonYear
          recordsToDelete.push(record)
        end
      end
      # Delete after going through the loop, otherwise it will mess everything up
      recordsToDelete.each do |r|
        @harvestrecords.delete(r)
      end
    end
    
    if @harvestrecords
      render :action => :showByPlantingRecordId
    else
      redirect :action => :index
    end
  end

  # GET /HarvestRecord/new/{parentPlantingRecordId}
  def new
    @harvestrecord = HarvestRecord.new
    @harvestrecord.PlantingRecordId = @params['id']
      
    self.setMinMaxDate(PlantingRecord.find(:first, :conditions => {{:name => "PlantingRecordId", :op => "LIKE"} => @params['id']}))
    initDate = Time.new()
    if ((initDate <=> @maxDate) == 1) then initDate = @maxDate end
    if ((initDate <=> @minDate) == -1) then initDate = @minDate end 
    @harvestrecord.HarvestDate = initDate.strftime("%Y-%m-%d")
    
    # Get the harvest record with the highest harvest record id(the one that was created last)
    lastHarvestRecord = nil
    # Just in case the HarvestRecord table wasn't created yet (i.e. no harvest records created yet)
    begin
      lastHarvestRecord = HarvestRecord.find(:first, :order => 'HarvestRecordId', :orderdir => 'DESC')
    rescue
      lastHarvestRecord = nil
    end
    # Set the new harvest record id
    if lastHarvestRecord != nil
      @harvestrecord.HarvestRecordId = lastHarvestRecord.HarvestRecordId + 1
    else
      @harvestrecord.HarvestRecordId = 0
    end
    
    # Get the amount units
    @amountUnits = AmountUnit.find(:all, :order => "UnitNamePlural")
      
    render :action => :new
  end

  # GET /HarvestRecord/edit/{HarvestRecordId}
  def edit
    @harvestrecord = HarvestRecord.find(:first, :conditions => {{:name => "HarvestRecordId", :op => "LIKE"} => @params['id']})
      
    # Get the amount units
    @amountUnits = AmountUnit.find(:all, :order => "UnitNamePlural")
         
    self.setMinMaxDate(PlantingRecord.find(:first, :conditions => {{:name => "PlantingRecordId", :op => "LIKE"} => @harvestrecord.PlantingRecordId}))
    if @harvestrecord
      render :action => :edit
    else
      redirect :action => :index
    end
  end

  # POST /HarvestRecord/create
  def create
    # unformat the harvest date for database
    @params['harvestrecord']['HarvestDate'] = Time.parse(@params['harvestrecord']['HarvestDate'], "%b %-d, %Y")
    @harvestrecord = HarvestRecord.create(@params['harvestrecord'])
  end

  # POST /HarvestRecord/{1}/update
  def update
    # unformat the harvest date for database
    @params['harvestrecord']['HarvestDate'] = Time.parse(@params['harvestrecord']['HarvestDate'], "%b %-d, %Y")
    
    @harvestrecord = HarvestRecord.find(@params['id'])
    @harvestrecord.update_attributes(@params['harvestrecord']) if @harvestrecord
  end

  # POST /HarvestRecord/{1}/delete
  def delete
    @harvestrecord = HarvestRecord.find(@params['id'])
    plantingRecordId = @harvestrecord.PlantingRecordId
    @harvestrecord.destroy if @harvestrecord
    redirect '/app/HarvestRecord/showByPlantingRecordId/' + plantingRecordId.to_s
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
