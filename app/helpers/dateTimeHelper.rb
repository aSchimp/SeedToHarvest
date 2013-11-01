require 'date'
require 'time'

module DateTimeHelper
  
  def popupDateTimePicker
      fieldId = @params['fieldId']
      currentFieldDate = @params['oldDate']
      if(currentFieldDate.nil? || currentFieldDate == '')
        preset_time = Time.new
      else
        preset_time = Time.parse(currentFieldDate, "%b %-d, %Y")
      end
      
      DateTimePicker.set_change_value_callback url_for(:action => :dateTimePickerCallback)
      current_value = Time.at(preset_time).strftime('%b %-d, %Y')
      WebView.execute_js('DateTimeHelper.setFieldValue("' + fieldId + '","'+current_value+'");')
      oldValue = currentFieldDate
      if oldValue.nil?              
        oldValue = ''
      end
      
      min = Time.parse(@params['min']) if @params['min']
      max = Time.parse(@params['max']) if @params['max']
      
      if min.nil? || max.nil?
        DateTimePicker.choose_with_range(url_for(:action => :dateTimePickerCallback), 'Select Input Date', preset_time, 1, oldValue + '*' + fieldId)
      else
        DateTimePicker.choose_with_range(url_for(:action => :dateTimePickerCallback), 'Select Input Date', preset_time, 1, oldValue + '*' + fieldId, min, max)
      end
      
      render :string => ''  #, :back => 'callback:' + url_for(:action => :callback_alert)   
    end
    
    def dateTimePickerCallback
      opaque = @params['opaque'].split('*')
      oldValue = opaque[0]
      fieldId = opaque[1]
      
      if @params['status'] == 'ok'
        formatted_result = Time.at(@params['result'].to_i).strftime('%b %-d, %Y')
        WebView.execute_js('DateTimeHelper.setFieldValue("' + fieldId + '","'+formatted_result+'");')
      end
      if @params['status'] == 'cancel'
        WebView.execute_js('DateTimeHelper.setFieldValue("' + fieldId + '","'+oldValue+'");')
      end
      if @params['status'] == 'change'
        formatted_result = Time.at(@params['result'].to_i).strftime('%b %-d, %Y')
        WebView.execute_js('DateTimeHelper.setFieldValue("' + fieldId + '","'+formatted_result+'");')
      end
    end
end