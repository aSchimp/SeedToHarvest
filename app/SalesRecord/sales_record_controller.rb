require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'helpers/dateTimeHelper'

class SalesRecordController < Rho::RhoController
  include BrowserHelper
  include DateTimeHelper

  # GET /SalesRecord/showByPlantingRecordId/{parentPlantingRecordId}
  def showByPlantingRecordId
    @plantingRecordId = @params['id']
    @salesrecords = SalesRecord.find(:all, :conditions => {{:name => "PlantingRecordId", :op => "LIKE"} => @plantingRecordId}, :order => ["Date", "Buyer"])
    # For biennial and perennial crops
    if @@currentlySelectedCropType == 1 || @@currentlySelectedCropType == 2
      selSeasonYear = $memoryData.AppSettings.selectedSeasonYear
      recordsToDelete = []
      @salesrecords.each do |record|
        if(Time.parse(record.Date).year != selSeasonYear)
          recordsToDelete.push(record)
        end
      end
      recordsToDelete.each do |r|
        @salesrecords.delete(r)
      end
    end
    
    if @salesrecords
      render :action => :showByPlantingRecordId
    else
      redirect :action => :index
    end
  end

  # GET /SalesRecord/new/{parentPlantingRecordId}
  def new
    @salesrecord = SalesRecord.new
    @salesrecord.PlantingRecordId = @params['id']
      
    # Set up the date field and date picker
    self.setMinMaxDate(PlantingRecord.find(:first, :conditions => {{:name => "PlantingRecordId", :op => "LIKE"} => @params['id']}))
    initDate = Time.new()
    if ((initDate <=> @maxDate) == 1) then initDate = @maxDate end
    if ((initDate <=> @minDate) == -1) then initDate = @minDate end 
    @salesrecord.Date = initDate.strftime("%Y-%m-%d")
    
    # Get the sales record with the highest sales record id(the one that was created last)
    lastSalesRecord = nil
    # Just in case the SalesRecord table wasn't created yet (i.e. no sales records created yet)
    begin
      lastSalesRecord = SalesRecord.find(:first, :order => 'SalesRecordId', :orderdir => 'DESC')
    rescue
      lastSalesRecord = nil
    end
    # Set the new sales record id
    if lastSalesRecord != nil
      @salesrecord.SalesRecordId = lastSalesRecord.SalesRecordId + 1
    else
      @salesrecord.SalesRecordId = 0
    end
    
    # Get Amount Units
    @amountUnits = AmountUnit.find(:all, :order => "UnitNamePlural")
      
    render :action => :new
  end

  # GET /SalesRecord/edit/{salesRecordId}
  def edit
    @salesrecord = SalesRecord.find(:first, :conditions => {{:name => "SalesRecordId", :op => "LIKE"} => @params['id']})
      
    self.setMinMaxDate(PlantingRecord.find(:first, :conditions => {{:name => "PlantingRecordId", :op => "LIKE"} => @salesrecord.PlantingRecordId}))

    # Get Amount Units
    @amountUnits = AmountUnit.find(:all, :order => "UnitNamePlural")
      
    if @salesrecord
      render :action => :edit
    else
      redirect :action => :index
    end
  end

  # POST /SalesRecord/create
  def create
    # unformat the sales date for database
    @params['salesrecord']['Date'] = Time.parse(@params['salesrecord']['Date'], "%b %-d, %Y")
    @salesrecord = SalesRecord.create(@params['salesrecord'])
  end

  # POST /SalesRecord/{1}/update
  def update
    @salesrecord = SalesRecord.find(@params['id'])
      
    # unformat the sales date for database
    @params['salesrecord']['Date'] = Time.parse(@params['salesrecord']['Date'], "%b %-d, %Y")
      
    @salesrecord.update_attributes(@params['salesrecord']) if @salesrecord
  end

  # POST /SalesRecord/{1}/delete
  def delete
    @salesrecord = SalesRecord.find(@params['id'])
    plantingRecordId = @salesrecord.PlantingRecordId
    @salesrecord.destroy if @salesrecord
    redirect '/app/SalesRecord/showByPlantingRecordId/' + plantingRecordId.to_s
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
