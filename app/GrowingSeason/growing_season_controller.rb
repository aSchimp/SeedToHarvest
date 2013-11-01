require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'time'
require 'date'

class GrowingSeasonController < Rho::RhoController
  include BrowserHelper

  # GET /GrowingSeason
  def index
    @growingseasons = GrowingSeason.find(:all, :order => 'Year', :orderdir => 'DESC')
    render :back => '/app'
  end

  # GET /GrowingSeason/{1}
  def show
    @growingseason = GrowingSeason.find(@params['id'])
    if @growingseason
      render :action => :show, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # GET /GrowingSeason/new
  def new
    @growingseason = GrowingSeason.new
    @growingseason.Year = Time.new().year
    @years = self.getYears()
    render :action => :new, :back => url_for(:action => :index)
  end

  # GET /GrowingSeason/{1}/edit
  def edit
    @growingseason = GrowingSeason.find(@params['id'])
    @years = self.getYears()
    if @growingseason
      render :action => :edit, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # POST /GrowingSeason/create
  def create
    # In case there is already a GrowingSeason with the selected year.
    begin
      @growingseason = GrowingSeason.create(@params['growingseason'])
      render :string => "OK"
    rescue
      render :string => "FAIL"
    end
  end

  # POST /GrowingSeason/{1}/update
  def update
    @growingseason = GrowingSeason.find(@params['id'])
    
    # In case there is already a GrowingSeason with the selected year.
    begin
      @growingseason.update_attributes(@params['growingseason']) if @growingseason
      render :string => "OK"
    rescue
      render :string => "FAIL"
    end
  end

  # POST /GrowingSeason/{1}/delete
  def delete
    @growingseason = GrowingSeason.find(@params['id'])
    @growingseason.destroy if @growingseason
    redirect :action => :index  
  end
  
  def getYears
    years = []
    currentYear = Time.new().year
    beginYear = currentYear - 50
    endYear = currentYear + 1
    
    processYear = beginYear
    while(processYear < endYear + 1)
      years.push(processYear)
      processYear +=1
    end
    
    return years
  end
end
