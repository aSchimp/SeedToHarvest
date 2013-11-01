require 'rho/rhocontroller'
require 'helpers/browser_helper'

class HomeController < Rho::RhoController
  include BrowserHelper

  # GET /Home
  def index
    if(!$isFirstRun)
      $returnToPlantingHistoryOf = -1
      @growingSeasonsCount = GrowingSeason.find(:count)
      
      render :action => :index
    else
      $isFirstRun = false;
      if($restoreDataId != nil && $restoreDataId != "")
        redirect '/app/Settings/executeRestorePage'
      else
        render :action => :welcomePage
      end
    end
  end
  
  def gotoIndex
    redirect '/app/Home/index'
  end
  
  # GET /Home/farmInfo
  def farmInfo
    @farm = $memoryData.AppSettings
    render :action => :farmInfo
  end
  
  # POST /Home/updateFarmInfo
  def updateFarmInfo
    @farm = AppSettings.find(:first)
    $memoryData.AppSettings = @farm
    
    if(@params['farm']['reportIncludeFarmInfo'] == "on")
      @params['farm']['reportIncludeFarmInfo'] = "true"
    else
      @params['farm']['reportIncludeFarmInfo'] = "false"
    end
    
    @farm.update_attributes(@params['farm']) if @farm
    $memoryData.AppSettings = @farm
  end
  
  def changeCurrentYear
    settings = AppSettings.find(:first)
    settings.update_attributes({"selectedSeasonYear" => @params['id'].delete!("{").to_i})
    $memoryData.AppSettings = settings
    $memoryData.AppSettings.selectedSeasonYear = $memoryData.AppSettings.selectedSeasonYear.to_i
    redirect '/app/Home/index'
  end
  
  def showAlert
    message = @params['message']
    title = @params['title']
      
    if(message.nil? || message == "")
      Alert.show_popup(:title => title, :buttons => [{:id => "OK", :title => "OK"}])
    else
      Alert.show_popup(:message => message, :title => title, :buttons => [{:id => "OK", :title => "OK"}])
    end
  end
  
  def showDeleteConfirmAlert
    Alert.show_popup({:title => @params['title'] + "?", :buttons => [{:id => @params['confirmUrl'], :title => "Delete"}, "Cancel"], :callback => url_for(:action => :deleteConfirmCallback)})
  end
  
  def deleteConfirmCallback
    confirmUrl = @params["button_id"]
    title = @params["button_title"]
    if(title == "Delete")
      WebView.execute_js('$.mobile.changePage("' + confirmUrl + '", {transition: "slide", reverse: true});')
    end
  end
  
  def openExternalUrl
    url = @params['url']
    System.open_url(url)
  end

end
