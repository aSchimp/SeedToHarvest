require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'time'
require 'date'

class CropController < Rho::RhoController
  include BrowserHelper

  # GET /Crop
  def index
    @crops = Crop.find(:all, :order => "CropName")
    render :back => '/app/Home/gotoIndex'
  end
  
  # GET /Crop/editCropIndex
  def editCropIndex
    @crops = Crop.find(:all, :order => "CropName")
    render :back => '/app/Settings/index'
  end

  # GET /Crop/{1}
  def showPlantingRecords
    @crop = Crop.find(@params['id'])
    @@currentlySelectedCropObjectId = @params['id']
    @@currentlySelectedCropName = @crop.CropName
    @@currentlySelectedCropType = @crop.CropType
    @plantingRecords = nil
    
    case @crop.CropType
    when 0
      @plantingRecords = PlantingRecord.find(
                               :all,
                               :conditions => {
                                 {
                                   :name => "CropName",
                                   :op => "IN"
                                 } => @crop.CropName,
                                 {
                                   :name => "Year",
                                   :op => "LIKE"
                                 } => $memoryData.AppSettings.selectedSeasonYear,
                                 {
                                   :name => "IsActiveRecord",
                                   :op => "LIKE"
                                 } => 1
                               },
                               :op => "AND",
                               :order => ["CultivarName", "PlantingDate", "Location"]
                               )
    when 1
      selSeasonYear = $memoryData.AppSettings.selectedSeasonYear
      @plantingRecords = PlantingRecord.find(
                                           :all,
                                           :conditions => {
                                             {
                                               :name => "CropName",
                                               :op => "IN"
                                             } => @crop.CropName,
                                             {
                                               :name => "Year",
                                               :op => "LIKE"
                                             } => [selSeasonYear, selSeasonYear - 1],
                                             {
                                               :name => "IsActiveRecord",
                                               :op => "LIKE"
                                             } => 1
                                           },
                                           :op => "AND"
                                           )
    when 2
      @plantingRecords = PlantingRecord.find(
                                     :all,
                                     :conditions => {
                                       {
                                         :name => "CropName",
                                         :op => "IN"
                                       } => @crop.CropName,
                                       {
                                         :func => "CAST",
                                         :name => "PerennielClosingYear as INTEGER",
                                         :op => ">"
                                       } => $memoryData.AppSettings.selectedSeasonYear,
                                       {
                                         :name => "IsActiveRecord",
                                         :op => "LIKE"
                                       } => 1
                                     },
                                     :op => "AND"
                                     )
    end
    
    if(@crop.CropType != 0)
       recordsToDelete = []
       recordsToAdd = []                               
       @plantingRecords.each do |record|
         if(record.Year > $memoryData.AppSettings.selectedSeasonYear)
           recordsToDelete.push(record)
           
           parentRecord = record
           done = false
           while parentRecord.ParentRecordId > -1 && !done
             parentRecord = PlantingRecord.find(:first, :conditions => {{:name => "PlantingRecordId", :op => "LIKE"} => parentRecord.ParentRecordId})
             if(parentRecord.Year < $memoryData.AppSettings.selectedSeasonYear + 1)
               recordsToAdd.push(parentRecord)
               done = true
             end
           end
         end
       end
       recordsToDelete.each do |r|
         @plantingRecords.delete(r)
       end
       recordsToAdd.each do |r|
         if(@plantingRecords.index {|x| x.PlantingRecordId == r.PlantingRecordId} == nil)
           @plantingRecords.push(r)
         end
       end
       
      @plantingRecords.sort! do |x,y| 
        if(x.CultivarName == y.CultivarName)
          if(x.PlantingDate == y.PlantingDate)
            (x.Location <=> y.Location)
          else
            (x.PlantingDate <=> y.PlantingDate)
          end
        else
           (x.CultivarName <=> y.CultivarName)
        end
      end
    end
    
    if @plantingRecords
      render :action => :showPlantingRecords, :back => :index
    else
      redirect :action => :index
    end
  end

  # GET /Crop/new
  def new
    @crop = Crop.new
    
    @returnPage = @params['returnPage']
    if (@returnPage.nil? || @returnPage == "")
      @returnPage = '/app/Crop/index'
    end
    
    render :action => :new, :back => @returnPage
  end

  # GET /Crop/{1}/edit
  def edit
    @crop = Crop.find(@params['id'])
    if @crop
      render :action => :edit, :back => url_for(:action => :editCropIndex)
    else
      redirect :action => :editCropIndex
    end
  end

  # POST /Crop/create
  def create
    @params['crop']['CropName'] = @params['crop']['CropName'].strip
    
    # In case the crop already exists
    begin
      @crop = Crop.create(@params['crop'])
      render :string => "OK"
    rescue
      render :string => "FAIL"
    end
  end

  # POST /Crop/{1}/update
  def update
    @params['crop']['CropName'] = @params['crop']['CropName'].strip
    
    # In case the crop name is the same as another crop
    begin
      @crop = Crop.find(@params['id'])
      @crop.update_attributes(@params['crop']) if @crop
      render :string => "OK"
    rescue
      render :string => "FAIL"
    end
  end

  # POST /Crop/{1}/delete
  def delete
    @crop = Crop.find(@params['id'])
    cropName = @crop.CropName
    
    # Delete all records associated with this crop
    plantingRecords = PlantingRecord.find(:all, :conditions => {{:name => "CropName", :op => "LIKE"} => cropName})
    plantingRecords.each do |record|
      record.deleteAssocRecords()
      record.destroy
    end
    
    @crop.destroy if @crop
    
    redirect :action => :editCropIndex
  end
  
  def showPlantingRecordActionSheet
    WebView.execute_js("popupPlantingRecordActionSheet();")
  end
end
