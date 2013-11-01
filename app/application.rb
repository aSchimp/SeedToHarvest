require 'rho/rhoapplication'
require 'time'
require 'date'
require 'rho/rhotoolbar'

@@selectedYear = 0;
@@currentlySelectedCropName = ""
@@currentlySelectedCropObjectId = nil
@@currentlySelectedCropType = -1
$returnToPlantingHistoryOf = -1

$memoryData = DataBag.new

$restoreDataId = nil

$isFirstRun = false;


class AppApplication < Rho::RhoApplication
  
  def initialize
    
    $memoryData.AppSettings = AppSettings.find(:first)
    
    if $memoryData.AppSettings.nil?
      $isFirstRun = true;
      currentYear = Time.new().year
      GrowingSeason.create({"Year" => currentYear})
      $memoryData.AppSettings = AppSettings.create({'selectedSeasonYear' => currentYear})
    end
    
    if(AmountUnit.find(:count) < 1)
      AmountUnit.create({"UnitName" => "lb", "UnitNamePlural" => "lbs"})
      AmountUnit.create({"UnitName" => "bunch", "UnitNamePlural" => "bunches"})
      AmountUnit.create({"UnitName" => "bushel", "UnitNamePlural" => "bushels"})
      AmountUnit.create({"UnitName" => "head", "UnitNamePlural" => "heads"})
      AmountUnit.create({"UnitName" => "bag", "UnitNamePlural" => "bags"})
    end
    
    # Tab items are loaded left->right, @tabs[0] is leftmost tab in the tab-bar
    # Super must be called *after* settings @tabs!
    @tabs = nil
    #To remove default toolbar uncomment next line:
    @@toolbar = nil
    super
    
  end
  
  def on_activate_app
    startParams = System.get_start_params()
    # Alert.show_popup(:message => startParams, :title => "Start Parameters", :buttons => [{:id => "OK", :title => "OK"}])
    if(!startParams.nil?)
      startParams = startParams.strip
      if(startParams != "" && startParams != "params")
        if(startParams[0] != "-")
          $restoreDataId = startParams
          if(!$isFirstRun)
            WebView.navigate("/app/Settings/executeRestorePage")
          end
        end
      end
    end
    # Alert.show_popup(:message => $restoreDataId, :title => "Restore Data Id", :buttons => [{:id => "OK", :title => "OK"}])
  end
end
