require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'helpers/dateTimeHelper'


class PlantingRecordController < Rho::RhoController
  include BrowserHelper
  include DateTimeHelper
 

  # GET /PlantingRecord/showByPlantingRecordId/{1}
  # Optional Parameter {returnToPHid}: If this parameter is set then when leaving the page, will automatically return
  #                                    to the planting history of {returnToPHid} (must be a PlantingRecordId)
  def showByPlantingRecordId
    @plantingrecord = PlantingRecord.find(:first, :conditions => {{:name => "PlantingRecordId", :op => "LIKE"} => @params['id']})
    
    if(@params['returnToPHid'])
      $returnToPlantingHistoryOf = @params['returnToPHid'].to_i
    end
      
    if @plantingrecord
      render :action => :showByPlantingRecordId
    else
      redirect :action => :index
    end
  end
  
  # GET /PlantingRecord/showPlantingHistory/{1}
  def showPlantingHistory
    @plantingrecord = PlantingRecord.find(:first, :conditions => {{:name => "PlantingRecordId", :op => "LIKE"} => @params['id']})
      
    # Get the history
    @plantingRecords = []
    record = @plantingrecord
    while record.ParentRecordId > -1
      @plantingRecords.push(record)
      record = PlantingRecord.find(:first, :conditions => {{:name => "PlantingRecordId", :op => "LIKE"} => record.ParentRecordId})
    end
    @plantingRecords.push(record)
    @plantingRecords.reverse!
    
    render :action => :showPlantingHistory
  end

  # GET /PlantingRecord/new
  def new
    @plantingrecord = PlantingRecord.new
    @plantingrecord.PlantingType = 0
    
    self.setMinMaxDate(@plantingrecord)
    initDate = Time.new()
    if ((initDate <=> @maxDate) == 1) then initDate = @maxDate end
    if ((initDate <=> @minDate) == -1) then initDate = @minDate end
    @plantingrecord.PlantingDate = initDate.strftime("%Y-%m-%d")
    
    # Get the planting record with the highest planting record id(the one that was created last)
    lastPlantingRecord = nil
    # Just in case the PlantingRecord table wasn't created yet (i.e. no planting records created yet)
    begin
      lastPlantingRecord = PlantingRecord.find(:first, :order => 'PlantingRecordId', :orderdir => 'DESC')
    rescue
      lastPlantingRecord = nil
    end
    # Set the new planting record id
    if lastPlantingRecord != nil
      @newPlantingRecordId = lastPlantingRecord.PlantingRecordId + 1
    else
      @newPlantingRecordId = 0
    end
    
    render :action => :new
  end
  
  #GET /PlantingRecord/newPotOnRecord?id={parentRecordId}&cultivar={parentCultivarName}
  def newPotOnRecord
    @plantingrecord = PlantingRecord.new
    @plantingrecord.ParentRecordId = @params['id']
    @plantingrecord.CultivarName = @params['cultivar']
    @plantingrecord.PlantingType = 1
      
    self.setMinMaxDate(@plantingrecord)
    initDate = Time.new()
    if ((initDate <=> @maxDate) == 1) then initDate = @maxDate end
    if ((initDate <=> @minDate) == -1) then initDate = @minDate end
    @plantingrecord.PlantingDate = initDate.strftime("%Y-%m-%d")
                
    # Get the planting record with the highest planting record id(the one that was created last)
    lastPlantingRecord = nil
    # Just in case the PlantingRecord table wasn't created yet (i.e. no planting records created yet)
    begin
      lastPlantingRecord = PlantingRecord.find(:first, :order => 'PlantingRecordId', :orderdir => 'DESC')
    rescue
      lastPlantingRecord = nil
    end
    # Set the new planting record id
    if lastPlantingRecord != nil
      @newPlantingRecordId = lastPlantingRecord.PlantingRecordId + 1
    else
      @newPlantingRecordId = 0
    end
    
    render :action => :newPotOnRecord, :back => '/app/PlantingRecord/showByPlantingRecordId/' + @params['id']
  end
  
  #GET /PlantingRecord/newTransplantRecord?id={parentRecordId}&cultivar={parentCultivarName}
  def newTransplantRecord
    @plantingrecord = PlantingRecord.new
    @plantingrecord.ParentRecordId = @params['id']
    @plantingrecord.CultivarName = @params['cultivar']
    @plantingrecord.PlantingType = 2
    
    self.setMinMaxDate(@plantingrecord)
    initDate = Time.new()
    if ((initDate <=> @maxDate) == 1) then initDate = @maxDate end
    if ((initDate <=> @minDate) == -1) then initDate = @minDate end
    @plantingrecord.PlantingDate = initDate.strftime("%Y-%m-%d")
        
    # Get the planting record with the highest planting record id(the one that was created last)
    lastPlantingRecord = nil
    # Just in case the PlantingRecord table wasn't created yet (i.e. no planting records created yet)
    begin
      lastPlantingRecord = PlantingRecord.find(:first, :order => 'PlantingRecordId', :orderdir => 'DESC')
    rescue
      lastPlantingRecord = nil
    end
    # Set the new planting record id
    if lastPlantingRecord != nil
      @newPlantingRecordId = lastPlantingRecord.PlantingRecordId + 1
    else
      @newPlantingRecordId = 0
    end
    
    render :action => :newTransplantRecord, :back => '/app/PlantingRecord/showByPlantingRecordId/' + @params['id']
  end

  # GET /PlantingRecord/{1}/edit
  def edit
    @plantingrecord = PlantingRecord.find(@params['id'])
    self.setMinMaxDate(@plantingrecord)
      
    if @plantingrecord
      render :action => :edit, :back => url_for(:action => :index)
    else
      $returnToPlantingHistoryOf = -1
      redirect :action => :index
    end
  end

  # POST /PlantingRecord/create
  def create
    #unformat the planting date for the database
    @params['plantingrecord']['PlantingDate'] = Time.parse(@params['plantingrecord']['PlantingDate'], "%b %-d, %Y")
    
    @plantingrecord = PlantingRecord.create(@params['plantingrecord'])
    
    # if there is not more of the original planting, then hide the parent record
    isMoreOfOriginalPlanting = @params['isMoreOfOriginalPlanting']
    if(isMoreOfOriginalPlanting.nil? || isMoreOfOriginalPlanting == 0)
      # if this record has a parent record...
      if @plantingrecord.ParentRecordId.to_i > -1
        #... make sure to set that the parent record is no longer an active record
        parentRecord = PlantingRecord.find(:first, :conditions => {{:name => "PlantingRecordId", :op => "LIKE"} => @plantingrecord.ParentRecordId})
        parentRecord.update_attributes({"IsActiveRecord" => 0})
      end
    end
    
    $returnToPlantingHistoryOf = -1
  end

  # POST /PlantingRecord/{1}/update
  def update
    #unformat the planting date for the database
    @params['plantingrecord']['PlantingDate'] = Time.parse(@params['plantingrecord']['PlantingDate'], "%b %-d, %Y")
      
    db = ::Rho::RHO.get_src_db('PlantingRecord')
    db.start_transaction
    begin
      @plantingrecord = PlantingRecord.find(@params['id'])
      @plantingrecord.update_attributes(@params['plantingrecord']) if @plantingrecord
        
        
      newCultivarName = @plantingrecord.CultivarName
      topLevelRecord = @plantingrecord  
      if(topLevelRecord.ParentRecordId > -1)
        while(topLevelRecord.ParentRecordId > -1)
          topLevelRecord = PlantingRecord.find(:first, :conditions => {{:name => "PlantingRecordId", :op => "LIKE"} => topLevelRecord.ParentRecordId})
        end        
      end
      self.updateCultivarNameWithChildRecords(newCultivarName, topLevelRecord)
        
      db.commit
    rescue
      db.rollback
    end
    
    $returnToPlantingHistoryOf = -1
  end
  
  # updates the cultivar name - and also changes the cultivar name of any child records
  def updateCultivarNameWithChildRecords(newCultivarName, plantingRecord)
    plantingRecord.update_attributes({"CultivarName" => newCultivarName})
      
    # update child records
    childRecords = PlantingRecord.find(:all, :conditions => {{:name => "ParentRecordId", :op => "LIKE"} => plantingRecord.PlantingRecordId})
    childRecords.each do |record|
      self.updateCultivarNameWithChildRecords(newCultivarName, record)
    end
  end

  # POST /PlantingRecord/{1}/delete
  def delete
    @plantingrecord = PlantingRecord.find(@params['id'])
    
    db = ::Rho::RHO.get_src_db('PlantingRecord')
    db.start_transaction
    begin
      #delete child records
      self.deleteChildRecords(@plantingrecord)
      
      # if there are no sibling records, make the parent record visible in the main view 
      # if the number of records with the same ParentRecordId < 2 because the record being deleted is counted also
      if (PlantingRecord.find(:count, :conditions => {{:name => "ParentRecordId", :op => "LIKE"} => @plantingrecord.ParentRecordId}) < 2)
        parentRecord = PlantingRecord.find(:first, :conditions => {{:name => "PlantingRecordId", :op => "LIKE"} => @plantingrecord.ParentRecordId})
        parentRecord.update_attributes({"IsActiveRecord" => "1"}) if parentRecord
      end
        
      @plantingrecord.deleteAssocRecords()
      @plantingrecord.destroy if @plantingrecord
      
      db.commit
    rescue
      db.rollback
    end
    
    $returnToPlantingHistoryOf = -1
    redirect '/app/Crop/showPlantingRecords/' + @@currentlySelectedCropObjectId
  end
  
  def deleteChildRecords(parentRecord)
    childRecords = PlantingRecord.find(:all, :conditions => {{:name => "ParentRecordId", :op => "LIKE"} => parentRecord.PlantingRecordId})
    childRecords.each do |record|
      self.deleteChildRecords(record)
      
      # Delete associated input, harvest, and sales records
      record.deleteAssocRecords()
      
      record.destroy if record
    end
  end
  
  # GET /PlantingRecord/removeFromThisYearsRecords/{PlantingRecordId} @params['id]
  # For use with perennial crops only.  Sets the PerennielClosingYear of the PlantingRecord to the current season year
  #                                     being viewed.
  def removeFromThisYearsRecords
    @plantingrecord = PlantingRecord.find(:first, :conditions => {{:name => "PlantingRecordId", :op => "LIKE"} => @params['id']})
    @plantingrecord.update_attributes({"PerennielClosingYear" => $memoryData.AppSettings.selectedSeasonYear}) if @plantingrecord
    redirect '/app/Crop/showPlantingRecords/' + @@currentlySelectedCropObjectId
  end
  
  # Sets $returnToPlantingHistoryOf to {value} a parameter
  # this method is for ajax calls from javascript
  def setReturnToPlantingHistoryOf()
    $returnToPlantingHistoryOf = @params['value'].to_i
  end
  
  # Sets @minDate and @maxDate for the date-time picker based on @@currentlySelectedCropType and $memoryData.AppSettings.selectedSeasonYear
  # and plantingRecord Type
  def setMinMaxDate(plantingRecord)
    selSeasonYear = $memoryData.AppSettings.selectedSeasonYear
    plantingType = plantingRecord.PlantingType
    
    if plantingType == 0
      case @@currentlySelectedCropType
      when 0
        @minDate = Time.utc(selSeasonYear - 1, 7, 1)
        @maxDate = Time.utc(selSeasonYear + 1, 6, 30)
      when 1,2
        @minDate = Time.utc(selSeasonYear, 1, 1)
        @maxDate = Time.utc(selSeasonYear, 12, 31)
      end
    end
    
    if plantingType == 1 || plantingType == 2
      parentRecord = PlantingRecord.find(:first, :conditions => {{:name => "PlantingRecordId", :op => "LIKE"} => plantingRecord.ParentRecordId})
      case @@currentlySelectedCropType
       when 0
         @minDate = parentRecord.PlantingDate
         @maxDate = Time.utc(selSeasonYear + 1, 6, 30)
       when 1,2
         @minDate = Time.utc(selSeasonYear, 1, 1)
         if ((@minDate <=> parentRecord.PlantingDate) == -1) then @minDate = plantingRecord.PlantingDate end
         @maxDate = Time.utc(selSeasonYear, 12, 31)
       end
    end
  end
  
end
