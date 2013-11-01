require 'rho'
require 'rho/rhocontroller'
require 'rho/rhoerror'
require 'helpers/browser_helper'
require 'json'
require 'rexml/document'
require 'date'
require 'time'

class SettingsController < Rho::RhoController
  include BrowserHelper
  
  def index
    @msg = @params['msg']
    render
  end
  
  def makeBackup
    render :action => :makeBackup
  end
  
  def sendBackup
    begin
      emailAddress = Rho::RhoSupport.url_encode(@params['backupEmail'])
      data = Rho::RhoSupport.url_encode(getAllDataAsJSON())
      key = ""
      backupServiceUrl = "" # Put the url for the backup service here
      Rho::AsyncHttp.post(
            :url => backupServiceUrl,
            :body => "email=" + emailAddress + "&data=" + data + "&key=" + key,
            :callback => url_for(:action => :sendBackup_httppost_callback),
            :callback_param => "post=complete"
          )
      
      render :string => "OK"
    rescue
      render :string => "FAILED"
    end
  end
  
  def sendBackup_httppost_callback
    begin
      if @params["http_error"] == "200"
        WebView.execute_js('successHandler();')
      else
        if @params["http_error"].nil? || @params["http_error"] == ""
          if(@params['error_code'] == "1")
            WebView.execute_js('noNetworkHandler();')
          else
            WebView.execute_js('errorHandler("Unknown");')
          end
        else
          WebView.execute_js('errorHandler("' + @params["http_error"] + '");')
        end
      end
    rescue
      WebView.execute_js('errorHandler("App Error");')
    end
  end
  
  # Returns a json string containing all data from the database
  def getAllDataAsJSON
    data = DataBag.new
    data.AmountUnits = AmountUnit.find(:all)
    data.AppSettings = AppSettings.find(:first)
    data.Crops = Crop.find(:all)
    data.Fields = Field.find(:all)
    data.FieldRecords = FieldRecord.find(:all)
    data.GrowingSeasons = GrowingSeason.find(:all)
    data.HarvestRecords = HarvestRecord.find(:all)
    data.InputRecords = InputRecord.find(:all)
    data.MiscRecords = MiscRecord.find(:all)
    data.PlantingRecords = PlantingRecord.find(:all)
    data.SalesRecords = SalesRecord.find(:all)
    
    return ::JSON.generate(data)
  end
  
  def restoreInstructions
    digits = Time.now().strftime("%j").split(//)
    digits[0] = format("%.0f",(digits[0].to_f + 3))
    digits[1] = format("%.0f",(digits[1].to_f + 16))
    digits[2] = format("%.0f",(digits[2].to_f + 22))
    
    @accessCode = "C" + digits[1] + digits[0] + "JF" + digits[2]
  end
  
  def executeRestore
    begin
      backupDataId = @params['backupDataId']
      key = ""
      restoreSericeUrl = "" # TODO: put the url for the restore service here
      Rho::AsyncHttp.post(
            :url => restoreSericeUrl,
            :body => "dataId=" + backupDataId + "&key=" + key,
            :callback => url_for(:action => :restoreBackup_httppost_callback),
            :callback_param => "post=complete"
          )
      
      render :string => "OK"
    rescue
      render :string => "FAILED"
    end
  end
  
  def restoreBackup_httppost_callback
    begin
     if @params["http_error"] == "200"
       
       doc = REXML::Document.new(@params['body'].to_s)
       jsonString = doc.root.get_text.value
       obj = Rho::JSON.parse(jsonString)
       # Do the restore
       doRestore(obj)
         
       WebView.execute_js('successHandler();')
     else
       if @params["http_error"].nil? || @params["http_error"] == ""
         if(@params['error_code'] == "1")
           WebView.execute_js('noNetworkHandler();')
         else
           WebView.execute_js('errorHandler("Unknown");')
         end
       else
         WebView.execute_js('errorHandler("' + @params["http_error"] + '");')
       end
     end
   rescue
     WebView.execute_js('errorHandler("App Error");')
   end
  end
  
  def doRestore(data)
    require_source 'Crop'
    db = Rho::RHO.get_src_db('Crop')
    db.start_transaction
    begin
      # Reset the database
      Rhom::Rhom.database_full_reset
      
      data["AmountUnits"].each do |amountUnit|
        AmountUnit.create(amountUnit)
      end
      
      AppSettings.create(data["AppSettings"])
        
      data["Crops"].each do |crop|
        Crop.create(crop)
      end
      
      data["Fields"].each do |field|
        Field.create(field)
      end
      
      data["FieldRecords"].each do |fieldRecord|
        FieldRecord.create(fieldRecord)
      end
        
      data["GrowingSeasons"].each do |growingSeason|
        GrowingSeason.create(growingSeason)
      end
      
      data["HarvestRecords"].each do |harvestRecord|
        HarvestRecord.create(harvestRecord)
      end
      
      data["InputRecords"].each do |inputRecord|
        InputRecord.create(inputRecord)
      end
      
      data["MiscRecords"].each do |miscRecord|
        MiscRecord.create(miscRecord)
      end
      
      data["PlantingRecords"].each do |plantingRecord|
        PlantingRecord.create(plantingRecord)
      end
      
      data["SalesRecords"].each do |salesRecord|
        SalesRecord.create(salesRecord)
      end
      
      db.commit
    rescue
      db.rollback
    end
    
  end
  
  def reset
    render :action => :reset
  end
  
  def do_reset
    Rhom::Rhom.database_full_reset
    
    # Set up default settings
    currentYear = Time.new().year
    GrowingSeason.create({"Year" => currentYear})
    $memoryData.AppSettings = AppSettings.create({'selectedSeasonYear' => currentYear})
        
    AmountUnit.create({"UnitName" => "lb", "UnitNamePlural" => "lbs"})
    AmountUnit.create({"UnitName" => "bunch", "UnitNamePlural" => "bunches"})
    AmountUnit.create({"UnitName" => "bushel", "UnitNamePlural" => "bushels"})
    AmountUnit.create({"UnitName" => "head", "UnitNamePlural" => "heads"})
    AmountUnit.create({"UnitName" => "bag", "UnitNamePlural" => "bags"})
    
    @msg = "Database has been reset."
    redirect :action => :index, :query => {:msg => @msg}
  end
end
