require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'helpers/dateTimeHelper'

class FieldRecordController < Rho::RhoController
  include BrowserHelper
  include DateTimeHelper

  # GET /FieldRecord
  def index
    @fields = Field.find(:all, :order => "FieldName")
    render :back => '/app'
  end

  # GET /FieldRecord/showbyFieldName/{FieldName (@params['id'])}
  def showByFieldName
    @fieldName = @params['id']
    @fieldrecords = FieldRecord.find(:all, :conditions => {
                                            {:name => "FieldName", :op => "LIKE"} => @fieldName,
                                            {:name => "Year", :op => "LIKE"} => $memoryData.AppSettings.selectedSeasonYear},
                                             :order => ["Date", "Section", "Description"])
    if @fieldrecords
      render :action => :showByFieldName
    else
      redirect :action => :index
    end
  end

  # GET /FieldRecord/new/{fieldName @params['id']}
  def new
    @fieldrecord = FieldRecord.new
    @fieldrecord.FieldName = @params['id']
    initDate = Time.new()
    selSeasonYear = $memoryData.AppSettings.selectedSeasonYear
    if initDate.year != selSeasonYear then initDate = Time.new(selSeasonYear) end
    @fieldrecord.Date = initDate.strftime("%Y-%m-%d")
    
    self.setStartAndEndOfYear()
    
    # Get the field record with the highest field record id(the one that was created last)
    lastFieldRecord = nil
    # Just in case the FieldRecord table wasn't created yet (i.e. no field records created yet)
    begin
      lastFieldRecord = FieldRecord.find(:first, :order => 'FieldRecordId', :orderdir => 'DESC')
    rescue
      lastFieldRecord = nil
    end
    # Set the new field record id
    if lastFieldRecord != nil
      @fieldrecord.FieldRecordId = lastFieldRecord.FieldRecordId + 1
    else
      @fieldrecord.FieldRecordId = 0
    end
    
    render :action => :new
  end

  # GET /FieldRecord/{1}/edit
  def edit
    @fieldrecord = FieldRecord.find(@params['id'])
      
    self.setStartAndEndOfYear()
      
    if @fieldrecord
      render :action => :edit, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # POST /FieldRecord/create
  def create
    # unformat the field record date for the database
    @params['fieldrecord']['Date'] = Time.parse(@params['fieldrecord']['Date'], "%b %-d, %Y")
    
    @fieldrecord = FieldRecord.create(@params['fieldrecord'])
    
  end

  # POST /FieldRecord/{1}/update
  def update
    # unformat the field record date for the database
    @params['fieldrecord']['Date'] = Time.parse(@params['fieldrecord']['Date'], "%b %-d, %Y")
    
    @fieldrecord = FieldRecord.find(@params['id'])
    @fieldrecord.update_attributes(@params['fieldrecord']) if @fieldrecord
      
  end

  # POST /FieldRecord/{1}/delete
  def delete
    @fieldrecord = FieldRecord.find(@params['id'])
    fieldName = @fieldrecord.FieldName
    @fieldrecord.destroy if @fieldrecord
    redirect '/app/FieldRecord/showByFieldName/' + fieldName
  end
  
  # Sets @startOfYear and @endOfYear based on $memoryData.AppSettings.selectedSeasonYear
  def setStartAndEndOfYear
    selSeasonYear = $memoryData.AppSettings.selectedSeasonYear
    @startOfYear = Time.utc(selSeasonYear, 1, 1)
    @endOfYear = Time.utc(selSeasonYear, 12, 31)
  end
  
end
