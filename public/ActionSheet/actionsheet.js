var ActionSheet = {
     buttonData: [],


	/**
	 *
	 * Event handler
	 *
	 */

	handleEvent: function (e) {
		var i=0;
	    if (e.type == 'touchstart') {
			this.lockScreen(e);
			
			for(i=0; i<this.buttonData.length; i++)
			{
				if (e.currentTarget.id == this.buttonData[i].id) {
					this.tapDown(e);
				}
			}
		} 
	    else if (e.type == 'touchend') {
            
			for(i=0; i<this.buttonData.length; i++)
			{
			    if (e.currentTarget.id == this.buttonData[i].id) {
					this.tapUp(e);
				}
			}
		} else if (e.type == 'webkitTransitionEnd') {
			if (e.target.id == 'as-wrapper') {
				this.destroy();
			}
		} else if (e.type == 'orientationchange') {
			this.onOrientationChange(e);
		} else if (e.type == 'scroll') {
			this.onScroll(e);
		}
		else if (e.type == 'click') {
		  
		  for(i=0; i<this.buttonData.length; i++)
		  {
			  if(e.target.id == this.buttonData[i].id) {
			  this.tapUp(e);
			   }
		  }
		} 
	},


	/**
	 *
	 * Global events
	 *
	 */

	onOrientationChange: function (e) {
		window.scrollTo(0, 0);
		this.asWrapper.style.top = window.innerHeight + window.pageYOffset + 'px';
		this.calculateSlotsWidth();
	},
	
	onScroll: function (e) {
		this.asWrapper.style.top = window.innerHeight + window.pageYOffset + 'px';
	},

	lockScreen: function (e) {
		e.preventDefault();
		e.stopPropagation();
	},


	/**
	 *
	 * Initialization
	 *
	 */

	reset: function () {
		this.asWrapper = undefined;
		this.asButtonWrapper = undefined;
		this.asButtonsContainer = undefined;
		this.asFrame = undefined;
	},

	create: function () {
		var button, l, out, ul, div;

		this.reset();	// Initialize object variables

		// Create the Spinning Wheel main wrapper
		div = document.createElement('div');
		div.id = 'as-wrapper';
		div.style.top = window.innerHeight + window.pageYOffset + 'px';		// Place the SW down the actual viewing screen
		div.style.webkitTransitionProperty = '-webkit-transform';
		div.innerHTML = '<div id="as-header">' + '</' + 'div><div id="as-button-wrapper"><div id="as-buttons-container"></' + 'div></' + 'div><div id="as-frame"></' + 'div>';

		document.body.appendChild(div);

		this.asWrapper = div;													// The SW wrapper
		this.asButtonWrapper = document.getElementById('as-button-wrapper');		// Slots visible area
		this.asButtonsContainer = document.getElementById('as-buttons-container');						// Pseudo table element (inner wrapper)
		this.asFrame = document.getElementById('as-frame');						// The scrolling controller

		for(var i=0; i<this.buttonData.length; i++)
		{
			button = document.createElement('div');
			button.id = this.buttonData[i].id;
			button.innerHTML = this.buttonData[i].title;
			button.className = this.buttonData[i].style + "-up";
			
			this.asButtonsContainer.appendChild(button);
			
			button.addEventListener('touchstart', this, false);
			
			// For the simulator
			button.addEventListener('click', this, false);
		}
		
		var x = this.asButtonWrapper.clientHeight;
		
		
		// Global events
		document.addEventListener('touchstart', this, false);			// Prevent page scrolling
		document.addEventListener('touchmove', this, false);			// Prevent page scrolling
		window.addEventListener('orientationchange', this, true);		// Optimize SW on orientation change
		window.addEventListener('scroll', this, true);				// Reposition SW on page scroll
	},

	open: function () {
		$.blockUI({message: null, overlayCSS: {opacity: 0.0}});
		this.create();

		this.asWrapper.style.webkitTransitionTimingFunction = 'ease-out';
		this.asWrapper.style.webkitTransitionDuration = '200ms';
		this.asWrapper.style.webkitTransform = 'translate3d(0, -' + this.asWrapper.clientHeight + 'px, 0)';
	},
	
	
	/**
	 *
	 * Unload
	 *
	 */

	destroy: function () {
		this.asWrapper.removeEventListener('webkitTransitionEnd', this, false);

		for(var i=0; i<this.buttonData.length; i++)
		{
			document.getElementById(this.buttonData[i].id).removeEventListener('touchstart', this, false);
		}

		document.removeEventListener('touchstart', this, false);
		document.removeEventListener('touchmove', this, false);
		window.removeEventListener('orientationchange', this, true);
		window.removeEventListener('scroll', this, true);
		
		this.reset();
		this.buttonData = [];
		
		document.body.removeChild(document.getElementById('as-wrapper'));
		
		$.unblockUI();
	},
	
	close: function () {
		this.asWrapper.style.webkitTransitionTimingFunction = 'ease-in';
		this.asWrapper.style.webkitTransitionDuration = '200ms';
		this.asWrapper.style.webkitTransform = 'translate3d(0, 0, 0)';
		
		this.asWrapper.addEventListener('webkitTransitionEnd', this, false);
	},


	/**
	 *
	 * Generic methods
	 *
	 */


	addButton: function(title, style, callback) {
	  var obj = {"id": "asButton" + this.buttonData.length, "title": title, "style": style, "callback": callback};
	  this.buttonData.push(obj);
    },
	


	/**
	 *
	 * Buttons
	 *
	 */

	tapDown: function (e) {
		e.currentTarget.addEventListener('touchend', this, false);
		e.currentTarget.className = e.currentTarget.className.replace("up", "down");
	},

	tapCancel: function (e) {
		e.currentTarget.removeEventListener('touchend', this, false);
		e.currentTarget.className = e.currentTarget.className.replace("down", "up");
	},
	
	tapUp: function (e) {
		this.tapCancel(e);

		for(var i=0; i<this.buttonData.length; i++)
		{
			if (e.currentTarget.id == this.buttonData[i].id)
			{
				this.buttonData[i].callback();
			} 
		}
		
		this.close();
	},

	/**
	 * 
	 * Specialized jquery mobile function for confirm delete action sheet
	 * 
	 */
	 
	 
	confirmDelete: function(confirmUrl, deleteButtonText)
	  {
	    if(navigator.userAgent.match(/iPad/i))
	    {
	    	$.post('/app/Home/showDeleteConfirmAlert?title=' + deleteButtonText + '&confirmUrl=' + encodeURI(confirmUrl));
	    }
	    else
	    {
		  	ActionSheet.addButton(deleteButtonText, "red", function() {$.mobile.changePage(confirmUrl, {transition: "slide", reverse: true});});
		    ActionSheet.addButton("Cancel", "cancel", function() {});
		    ActionSheet.open();
	    }
	  }
};