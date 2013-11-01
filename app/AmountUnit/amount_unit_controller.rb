require 'rho/rhocontroller'
require 'helpers/browser_helper'

class AmountUnitController < Rho::RhoController
  include BrowserHelper

  # GET /AmountUnit
  def index
    @amountunits = AmountUnit.find(:all)
    
    @returnPage = @params['returnPage']
    if @returnPage.nil? || @returnPage == ""
      @returnPage = '/app/Settings/index'
    end
    
    render :back => '/app'
  end

  # GET /AmountUnit/{1}
  def show
    @amountunit = AmountUnit.find(@params['id'])
    if @amountunit
      render :action => :show, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # GET /AmountUnit/new
  def new
    @amountunit = AmountUnit.new
    render :action => :new, :back => url_for(:action => :index)
  end

  # GET /AmountUnit/{1}/edit
  def edit
    @amountunit = AmountUnit.find(@params['id'])
    if @amountunit
      render :action => :edit, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # POST /AmountUnit/create
  def create
    # In case another AmountUnit with the same name already exists.
    begin
      @amountunit = AmountUnit.create(@params['amountunit'])
      render :string => "OK"
    rescue
      render :string => "FAIL"
    end
  end

  # POST /AmountUnit/{1}/update
  def update
    # In case another AmountUnit with the same name already exists.
    begin
      @amountunit = AmountUnit.find(@params['id'])
      @amountunit.update_attributes(@params['amountunit']) if @amountunit
      render :string => "OK"
    rescue
      render :string => "FAIL"
    end
  end

  # POST /AmountUnit/{1}/delete
  def delete
    @amountunit = AmountUnit.find(@params['id'])
    @amountunit.destroy if @amountunit
    redirect :action => :index  
  end
end
