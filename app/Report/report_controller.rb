require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'json'
require 'time'
require 'date'

class ReportController < Rho::RhoController
  include BrowserHelper
  
  def reportHome
    @crops = Crop.find(:all, :order => "CropName")
    @fields = Field.find(:all, :order => "FieldName")
    render :action => :reportHome
  end
  
  def generateReportFromReportHome
    cropReportType = "none"
    fieldReportType = "none"
    cropName = @params["cropSelector"]
    fieldName = @params["fieldSelector"]
    includeFarmInfo = @params["includeFarmInfo"]
    generateSummary = @params["summaryOption"]
      
    if(@params["radio-choice-1"] == "choice-1")
      cropReportType = "allCrop"
    else
      if(@params["radio-choice-1"] == "choice-2")
        cropReportType = "cropReport"
      end
    end
    
    if(@params["radio-choice-2"] == "choice-1")
      fieldReportType = "allField"
    else
      if(@params["radio-choice-2"] == "choice-2")
        fieldReportType = "fieldReport"
      end
    end
    
    if(!includeFarmInfo.nil? && includeFarmInfo == "on")
      includeFarmInfo = "true"
    else
      includeFarmInfo = "false"
    end
    
    if(!generateSummary.nil? && generateSummary == "on")
      generateSummary = "true"
    else
      generateSummary = "false"
    end
    
    redirect "/app/Report/reportViewer?cropReportType=#{cropReportType}&fieldReportType=#{fieldReportType}&cropName=#{cropName}&fieldName=#{fieldName}&includeFarmInfo=#{includeFarmInfo}&generateSummary=#{generateSummary}&returnPage=" + Rho::RhoSupport.url_encode("/app/Report/reportHome")
  end

  # @params['cropReportType']: valid values are: cultivarReport, cropReport, allCrop, none
  # @params['fieldReportType']: valid values are: allField, fieldReport, none
  # @params['plantingRecordId']: If 'cropReportType' == cultivarReport, this is the plantingRecordId of the record to
  #                              generate the report for.
  # @params['cropName']: If 'cropReportType' == cropReport, this is the crop name of the crop to generate the report for.
  # @params['fieldName']: If 'fieldReportType' == fieldReport, this is the field name of the field to generate the report for.
  # @params['includeFarmInfo']: Set to 'true' to include farm info on the report, 'false' to exclude it.  If not set,
  #                             value will default to the value set in AppSettings
  # @params['generateSummary']: Set to 'true' to generate summary report pages, otherwise set to 'false'
  # @params['returnPage']: The url of the page to return to when finished viewing the report.
  def reportViewer
    @cropReportType = @params['cropReportType']
    @fieldReportType = @params['fieldReportType']
    @plantingRecordId = @params['plantingRecordId']
    @cropName = @params['cropName']
    @fieldName = @params['fieldName']
    @includeFarmInfo = @params['includeFarmInfo']
    @generateSummary = @params['generateSummary']
    @returnPage = @params['returnPage']
      
    if(@returnPage.nil? || @returnPage == "")
      @returnPage = "/app/Report/reportHome"
    end
  end
  
  def httppost_callback
    # puts "#{@params['error_code']}"
    # Alert.show_popup(:message => @params["http_error"], :title => "http_error", :buttons => [{:id => "OK", :title => "OK"}])
    if(@params['error_code'] == "1")
      WebView.execute_js('noNetworkHandler();')
      return;
    end
    begin
      if @params["http_error"] == "200"
        reportId = @params['body']["d"]
          
        if(reportId.nil? || reportId == "")
          WebView.execute_js('errorHandler("Server Error");')
          return
        end
        
        WebView.execute_js('successHandler();')
        key = ""
        reportViewerUrl = "" # TODO: Put the url of the report viewer service here
        System.open_url("#{reportViewerUrl}?appName=seedtoharvest&reportId=#{reportId}&key=#{key}")
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
      if(@params['error_code'] == "1")
        WebView.execute_js('noNetworkHandler();')
      else
        WebView.execute_js('errorHandler("App Error");')
      end
    end
  end
  
  def generateReport
    begin
      @cropReportType = @params['cropReportType']
      @fieldReportType = @params['fieldReportType']
      @plantingRecordId = @params['plantingRecordId']
      @cropName = @params['cropName']
      @fieldName = @params['fieldName']
      @includeFarmInfo = @params['includeFarmInfo']
      @generateSummary = @params['generateSummary']
      @returnPage = @params['returnPage']
        
      cropReportData = nil
      
      if(@cropReportType == "cultivarReport")
        cropReportData = getCultivarReportData(@plantingRecordId)
      end
      
      if(@cropReportType == "cropReport")
        cropReportData = getCropReportData(@cropName)
      end
      
      if(@cropReportType == "allCrop")
        cropReportData = getAllReportData()
      end
      
      fieldReportData = nil
      
      if(@fieldReportType == "allField")
        fieldReportData = getAllFieldReportData()
      end
      
      if(@fieldReportType == "fieldReport")
        fieldReportData = getFieldReportData(@fieldName)
      end
      
      globalData = DataBag.new()
      
      globalData.ReportYear = $memoryData.AppSettings.selectedSeasonYear
      globalData.AmountUnits = AmountUnit.find(:all)
      
      if (!@generateSummary.nil? && @generateSummary == "true")
        globalData.GenerateSummary = true
      else
        globalData.GenerateSummary = false
      end
      
      if(@includeFarmInfo.nil? || @includeFarmInfo == "")
        if($memoryData.AppSettings.reportIncludeFarmInfo == "true")
          globalData.FarmInfo = getFarmInfo()
        end
      else
        if(@includeFarmInfo == "true")
          globalData.FarmInfo = getFarmInfo()
        end
      end
      
      type = ""
      cropJsonData = ""
      if(!cropReportData.nil?)
        type = @cropReportType
        cropJsonData = ::JSON.generate(cropReportData)
      end
      
      fieldJsonData = ""
      if(!fieldReportData.nil?)
        if(type != "")
          type += "+"
        end
        type += @fieldReportType
        fieldJsonData = ::JSON.generate(fieldReportData)
      end
      
      jsonGlobalData = ::JSON.generate(globalData)
      key = ""
      reportGeneratorUrl = "" # TODO: Put the url for the report generator service here
      type = Rho::RhoSupport.url_encode(type)
      Rho::AsyncHttp.post(
        :url => reportGeneratorUrl,
        :body => "reportType=" + type + "&cropData=" + cropJsonData + "&fieldData=" + fieldJsonData + "&globalData=" + jsonGlobalData + "&key=" + key,
        :callback => url_for(:action => :httppost_callback),
        :callback_param => "post=complete"
      )
      
      render :string => "OK"
    rescue
      render :string => "FAILED"
    end
  end
  
  def getFarmInfo()
    return AppSettings.find(:first, :select => ['FarmName', 'FarmOwner', 'FarmAddress1', 'FarmAddress2', 'FarmCity', 'FarmState', 'FarmZipCode', 'FarmRecordManager', 'FarmEmail', 'FarmPhone', 'FarmWebsite'])
  end
  
  def getAllReportData()
    reportData = DataBag.new
    reportData.CropReports = []
    
    crops = Crop.find(:all, :select => ["CropName"], :order => "CropName")
    
    crops.each do |c|
      reportData.CropReports.push(getCropReportData(c.CropName))
    end
    
    return reportData
  end
  
  def getCropReportData(cropName)
    reportData = DataBag.new
    reportData.CultivarReports = []
    crop = Crop.find(:first, :conditions => {{:name => "CropName", :op => "LIKE"} => cropName})
    
    plantingRecords = []
    if(crop.CropType == 0)
      plantingRecords = PlantingRecord.find(:all, :conditions => {{:name => "CropName", :op => "LIKE"} => cropName, {:name => "Year", :op => "LIKE"} => $memoryData.AppSettings.selectedSeasonYear, {:name => "IsActiveRecord", :op => "LIKE"} => 1}, :op => "AND", :select => ["PlantingRecordId", "CropName", "Year", "IsActiveRecord", "CultivarName", "PlantingDate", "Location"])
    end
    
    if(crop.CropType == 1)
      selSeasonYear = $memoryData.AppSettings.selectedSeasonYear
      plantingRecords = PlantingRecord.find(:all, :conditions => {{:name => "CropName", :op => "LIKE"} => cropName, {:name => "Year", :op => "LIKE"} => [selSeasonYear, selSeasonYear - 1], {:name => "IsActiveRecord", :op => "LIKE"} => 1}, :op => "AND", :select => ["PlantingRecordId", "ParentRecordId", "CropName", "Year", "IsActiveRecord", "CultivarName", "PlantingDate", "Location"])
    end
    
    if(crop.CropType == 2)
      plantingRecords = PlantingRecord.find(:all, :conditions => {{:name => "CropName", :op => "LIKE"} => cropName, {:func => "CAST", :name => "PerennielClosingYear as INTEGER", :op => ">"} => $memoryData.AppSettings.selectedSeasonYear, {:name => "IsActiveRecord", :op => "LIKE"} => 1}, :op => "AND", :select => ["PlantingRecordId", "ParentRecordId", "Year", "CropName", "PerennielClosingYear", "IsActiveRecord", "CultivarName", "PlantingDate", "Location"])
    end
    
    # For Biennial and Perennial reports
    if(crop.CropType != 0)
       recordsToDelete = []
       recordsToAdd = []                               
       plantingRecords.each do |record|
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
         plantingRecords.delete(r)
       end
       recordsToAdd.each do |r|
         if(plantingRecords.index {|x| x.PlantingRecordId == r.PlantingRecordId} == nil)
           plantingRecords.push(r)
         end
       end
    end
    
    plantingRecords.sort! do |x,y| 
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
    
    plantingRecords.each do |record|
      reportData.CultivarReports.push(getCultivarReportData(record.PlantingRecordId))
    end
    
    return reportData
  end
  
  def getCultivarReportData(plantingRecordId)
    reportData = DataBag.new
    reportData.PlantingHistory = self.getPlantingHistory(plantingRecordId)
    youngestRecord = reportData.PlantingHistory.last
    cropType = Crop.find(:first, :conditions => {{:name => "CropName", :op => "LIKE"} => youngestRecord.CropName}).CropType
    
    
    # Get Inputs
    inputs = []
    reportData.PlantingHistory.each do |pRecord|
      inputs += InputRecord.find(:all, :conditions => {{:name => "PlantingRecordId", :op => "LIKE"} => pRecord.PlantingRecordId})
    end
      
    if(cropType != 0)
      inputs.select!{|i| Time.parse(i.InputDate).year == $memoryData.AppSettings.selectedSeasonYear}
    end
      
    inputs.sort! {|x,y| x.InputDate <=> y.InputDate }
    reportData.InputRecords = inputs
    
    # Get Harvest Records
    harvestRecords = []
    reportData.PlantingHistory.each do |pRecord|
      harvestRecords += HarvestRecord.find(:all, :conditions => {{:name => "PlantingRecordId", :op => "LIKE"} => pRecord.PlantingRecordId})
    end
      
    if(cropType != 0)
      harvestRecords.select!{|hRecord| Time.parse(hRecord.HarvestDate).year == $memoryData.AppSettings.selectedSeasonYear}
    end
      
    harvestRecords.sort! {|x,y| x.HarvestDate <=> y.HarvestDate }
    reportData.HarvestRecords = harvestRecords
    
    # Get Sales Records
    salesRecords = []
    reportData.PlantingHistory.each do |pRecord|
      salesRecords += SalesRecord.find(:all, :conditions => {{:name => "PlantingRecordId", :op => "LIKE"} => pRecord.PlantingRecordId})
    end
      
    if(cropType != 0)
      salesRecords.select!{|sRecord| Time.parse(sRecord.Date).year == $memoryData.AppSettings.selectedSeasonYear}
    end
    
    salesRecords.sort! {|x,y| x.Date <=> y.Date }
    reportData.SalesRecords = salesRecords
    
    # Get Misc Records
    miscRecords = []
    reportData.PlantingHistory.each do |pRecord|
      miscRecords += MiscRecord.find(:all, :conditions => {{:name => "PlantingRecordId", :op => "LIKE"} => pRecord.PlantingRecordId})
    end
    
    if(cropType != 0)
      miscRecords.select!{|mRecord| Time.parse(mRecord.Date).year == $memoryData.AppSettings.selectedSeasonYear}
    end
    
    miscRecords.sort! {|x,y| x.Date <=> y.Date }
    reportData.MiscRecords = miscRecords
    
    return reportData
  end
  
  # Returns an array of PlantingRecords that are the parent records of the record with an id of{plantingRecordId}
  # also add the initial planting record to the array
  def getPlantingHistory(plantingRecordId)
    records = []
    plantingRecord = PlantingRecord.find(:first, :conditions => {{:name => "PlantingRecordId", :op => "LIKE"} => plantingRecordId})
    records.push(plantingRecord)
    
    while(plantingRecord.ParentRecordId > -1)
      plantingRecord = PlantingRecord.find(:first, :conditions => {{:name => "PlantingRecordId", :op => "LIKE"} => plantingRecord.ParentRecordId})
      records.push(plantingRecord)
    end
    
    records.reverse!
    
    return records
  end
  
  def getAllFieldReportData()
    reportData = DataBag.new
    reportData.FieldReports = []
      
    fields = Field.find(:all, :select => "FieldName", :order => "FieldName")
    
    fields.each do |f|
      reportData.FieldReports.push(getFieldReportData(f.FieldName))
    end
    
    return reportData
  end
  
  def getFieldReportData(fieldName)
    reportData = DataBag.new
    reportData.FieldName = fieldName
    reportData.FieldDescription = Field.find(:first, :conditions => {{:name => "FieldName", :op => "LIKE"} => fieldName}).FieldDescription
      
    reportData.FieldRecords = FieldRecord.find(:all, :conditions => {{:name => "FieldName", :op => "LIKE"} => fieldName}, :order => ["Date", "Section"])
      
    return reportData
  end
end
