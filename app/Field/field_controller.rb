require 'rho/rhocontroller'
require 'helpers/browser_helper'

class FieldController < Rho::RhoController
  include BrowserHelper

  # GET /Field
  def index
    @fields = Field.find(:all, :order => "FieldName")
    render :back => '/app'
  end

  # GET /Field/{1}
  def show
    @field = Field.find(@params['id'])
    if @field
      render :action => :show, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # GET /Field/new
  def new
    @field = Field.new
    
    @returnPage = @params["returnPage"]
    if(@returnPage.nil? || @returnPage == "")
      @returnPage = "/app/Field"
    end
    render :action => :new, :back => @returnPage
  end

  # GET /Field/{1}/edit
  def edit
    @field = Field.find(@params['id'])
    if @field
      render :action => :edit, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # POST /Field/create
  def create
    # In case the field name already belongs to another Field object
    begin
      @field = Field.create(@params['field'])
      
      render :string => "OK"
    rescue
      render :string => "FAIL"
    end
  end

  # POST /Field/{1}/update
  def update
    begin
      @field = Field.find(@params['id'])
      @field.update_attributes(@params['field']) if @field
      render :string => "OK"
    rescue
      render :string => "FAIL"
    end
  end

  # POST /Field/{1}/delete
  def delete
    @field = Field.find(@params['id'])
    fieldName = @field.FieldName
    
    # Delete records associated with this field
    fieldRecords = FieldRecord.find(:all, :conditions => {{:name => "FieldName", :op => "LIKE"} => fieldName})
    fieldRecords.each do |record|
      record.destroy
    end
    
    @field.destroy
    
    redirect :action => :index  
  end
end
