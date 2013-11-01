var DateTimeHelper = {
	
    setFieldValue: function (field, value) 
	{  
	  document.getElementById(field).value=value;
	},
	 
	// To use this function, the DateTimeHelper module must be included in the controller
	// from which this function is called
	//
	// fieldId: the field that the date-time picker will change the value of
	// controllerName: the full path and name of the controller of the current view
	popupDateTimePicker: function(fieldId, controllerName) 
	{
	  field = document.getElementById(fieldId);
	  $.get(controllerName + '/popupDateTimePicker', {oldDate: field.value, fieldId: fieldId});  
	  return false;
	},
	
	popupDateTimePickerMinMax: function(fieldId, controllerName, min, max)
	{
      field = document.getElementById(fieldId);
	  $.get(controllerName + '/popupDateTimePicker', {oldDate: field.value, fieldId: fieldId, min: min, max: max});  
	  return false;
	}
};