require 'rho/rhocontroller'
require 'helpers/browser_helper'

class AppSettingsController < Rho::RhoController
  include BrowserHelper

  # GET /AppSettings
  def index
    render :back => '/app'
  end

end
