( function( $ ) {

	/**
	 * UI object for the live event view
	 *
	 */
	var liveEntry = {

		/**
		 * This is the static event array for the live_entry view.
		 * Once the live_entry UI has been wired up to the database
		 * remove this file.
		 *
		 */
		eventLiveEntryStaticData: {
			eventName: "Hardrock 100 2016",
			splits: [
				{
					name: "Hardrock Clockwise Start",
					distance: 0.0,
					id: 0
				},
				{
					name: "KT",
					distance: 11.4,
					id: 1
				},
				{
					name: "Chapman",
					distance: 18.4,
					id: 2
				},
				{
					name: "Telluride",
					distance: 27.7,
					id: 3
				},
				{
					name: "Kroger",
					distance: 32.7,
					id: 4
				},
				{
					name: "Governor",
					distance: 36.0,
					id: 5
				},
				{
					name: "Ouray",
					distance: 43.9,
					id: 6
				},
				{
					name: "Engineer",
					distance: 51.8,
					id: 7
				},
				{
					name: "Grouse",
					distance: 58.3,
					id: 8
				},
				{
					name: "Burrows",
					distance: 67.9,
					id: 9
				},
				{
					name: "Sherman",
					distance: 71.7,
					id: 10
				},
				{
					name: "Pole Creek",
					distance: 71.7,
					id: 11
				},
				{
					name: "Maggie",
					distance: 85.1,
					id: 12
				},
				{
					name: "Cunningham",
					distance: 91.2,
					id: 13
				},
				{
					name: "Hardrock Clockwise Finish",
					distance: 100.5,
					id: 14
				}
			]
		},

		init: function() {

			// Sets the currentEventId once
			liveEntry.currentEventId = $( '#js-event-id' ).text();
			liveEntry.liveEntryForm();
			liveEntry.setStoredEfforts();
			liveEntry.addEffortToCache();
			liveEntry.updateEventName();
			liveEntry.buildSplitSelect();
			liveEntry.editEffort();
			liveEntry.buildSplitSlider();
		},

		/**
		 * Stores the ID for the current event
		 * this is pulled from the url and dumped on the page
		 * then stored in this variable
		 * @type integer
		 */
		currentEventId: null,

		/**
		 * When you type in a bib number into the live entry form this is set
		 * 
		 * @type integer
		 */
		currentEffortId: null,

		/**
		 * Set the initial cache object in local storage
		 *
		 * @return null
		 */
		efforts: {},

		/**
		 * Contains functionality for the effort form
		 *
		 */
		liveEntryForm: function() {

			// Apply input masks on time in / out
			var maskOptions = {
				placeholder: "HH:MM:SS",
				insertMode: false,
				showMaskOnHover: false,
			};

			$( '#js-time-in' ).inputmask( "hh:mm:ss", maskOptions );
			$( '#js-time-out' ).inputmask( "hh:mm:ss", maskOptions );

			/**
			 * Disables or enables fields for the effort lookup form
			 *
			 * @param bool 	True to enable, false to disable
			 */
			function toggleFields( enable ) {
				if ( enable == true ) {
					$( '#js-add-effort-form input:not(#js-bib-number)' ).removeAttr( 'disabled' );
				} else {
					$( '#js-add-effort-form input:not(#js-bib-number)' ).attr( 'disabled', 'disabled' );
					$( '#js-add-effort-form input:not(#js-bib-number)' ).val( '' );
					$( '#js-bib-number' ).val( '' );
				}
			}

			/**
			 * Clears out the splits slider data fields
			 *
			 */
			function clearSplitsData() {
				$( '#js-effort-name' ).html( '&nbsp;' );
				$( '#js-effort-last-reported' ).html( '&nbsp;' )
				$( '#js-effort-split-from' ).html( '&nbsp;' );
				$( '#js-effort-split-spent' ).html( '&nbsp;' );
				$( '#js-time-in' ).val( '' );
				$( '#js-time-out' ).val( '' );
				$( '#js-live-bib' ).val( '' );
				$( '#js-pacer-in' ).attr( 'checked', false );
				$( '#js-pacer-out' ).attr( 'checked', false );
			}

			/**
			 * Clears the live entry form when the clear button is clicked
			 * 
			 */
			$( '#js-clear-entry-form' ).on( 'click', function( event ) {
				event.preventDefault();
				clearSplitsData();
				toggleFields( false );
				return false;
			} );

			// Listen for keydown on bibNumber
			$( '#js-bib-number' ).on( 'keydown', function( event ) {

				// Check for tab or enter
				if ( event.keyCode == 13 || event.keyCode == 9 ) {
					event.preventDefault();
					var bibNumber = $( this ).val();
					if ( bibNumber == '' ) {
						toggleFields( false );
						clearSplitsData();
					} else {

						// Ajax endpoint for the effort data
						var data = { bibNumber: bibNumber };
						$.get( '/events/' + liveEntry.currentEventId + '/live_entry_ajax_get_effort', data, function( response ) {
							if ( response.success == true ) {
								liveEntry.currentEffortId = response.effortId;

								// If success == true, this means the bib number lookup found an "effort"
								$( '#js-live-bib' ).val( 'true' );
								$( '#js-effort-name' ).html( response.name );
								$( '#js-effort-last-reported' ).html( response.lastReportedSplitTime )
							} else {

								// If success == false, this means the bib number lookup failed, but we still need to capture the data
								$( '#js-live-bib' ).val( 'false' );
								$( '#js-effort-name' ).html( 'n/a' );
								$( '#js-effort-last-reported' ).html( 'n/a' )
							}
						} );
						toggleFields( true );
						$( '#js-time-in' ).focus();
					}
					return false;
				}
			} );

			$( '#js-time-in' ).on( 'keydown', function() {
				if ( event.keyCode == 13 || event.keyCode == 9 ) {
					var timeIn = $( this ).val();

					// Validate the military time string
					timeIn = timeIn.replace(/D/g, '');
					timeIn = timeIn.replace(/:/g, '');
					if ( timeIn.length == 6 ) {

						// currentEffortId may be null here
						var data = { timeIn:timeIn, effortId: liveEntry.currentEffortId };
						$.get( '/events/' + liveEntry.eventId + '/live_entry_ajax_get_time_from', data, function( response ) {
							console.log(response);
						} );
					} else {
						 $( this ).val( '' );
					}
				}
			} );

			$( '#js-time-out' ).on( 'keydown', function() {

			} );


			// Listen for keydown in pacer-in and pacer-out. Enter checks the box,
			// tab moves to next field.
			$( '#js-pacer-in, #js-pacer-out' ).on( 'keydown', function( event ) {
				var $this = $( this );
				switch ( $this.attr( 'id' ) ) {
					case '#js-pacer-in':
						$next = $( '#js-pacer-out' );
						break;
					case '#js-pacer-out':
						$next = $( '#js-add-to-cache' );
						break;
				}
				if ( $this.attr( 'id' ) == 'js-pacer-in' ) {
					$next = $( '#js-pacer-out' );
				}

				switch ( event.keyCode ) {
					case 13: // Enter pressed
						console.log($this.attr( 'checked' ));
						if ( $this.attr( 'checked' ) == 'checked' ) {
							$this.removeAttr( 'checked' );
						} else {
							$this.attr( 'checked', 'checked' );
						}
						break;
					case 9: // Tab pressed
						$next.focus();
						break;
				}
			} );
		},

		/**
		 * 
		 * 
		 */
		setStoredEfforts: function() {
			var effortsCache = localStorage.getItem( 'effortsCache' );
			if( effortsCache === null || effortsCache.length == 0 ) {
				localStorage.setItem( 'effortsCache', JSON.stringify( liveEntry.efforts ) );
			}
		},

		/**
		 * Get local data Efforts Storage Object
		 *
		 * @return object Returns object from local storage
		 */
		getStoredEfforts: function() {
			return JSON.parse( localStorage.getItem('effortsCache') )
		},

		/**
		 * Stringify then Save/Push all efforts to local object
		 *
		 * @param object effortsObject Pass in the object of the updated object with all added or removed objects.
		 * @return null
		 */
		saveStoredEfforts: function( effortsObject ) {
			localStorage.setItem( 'effortsCache', JSON.stringify( effortsObject ) );
			return null;
		},

		/**
		 * Delete the matching effort
		 *
		 * @param object 	effort 	Pass in the object/effort we want to delete.
		 * @return null
		 */
		deleteStoredEffort: function( effort ) {
			var storedEfforts = liveEntry.getStoredEfforts();
			var effortToDelete = JSON.stringify( effort );

			$.each( storedEfforts, function( index ) {
				var loopedEffort = JSON.stringify( $( this ) );
				if ( loopedEffort == effortToDelete ) {
					delete storedEfforts[index];
					return false;
				}
			} );

			localStorage.setItem( 'effortsCache', JSON.stringify( storedEfforts ) );
			return null;
		},

		/**
		 * Compare effort to all efforts in local storage. Add if it doesn't already exist, or throw an error message.
		 *
		 * @param  object effort Pass in Object of the effort to check it against the stored objects		 *
		 * @return boolean	True if match found, False if no match found
		 */
		isMatchedEffort: function( effort ) {
			var storedEfforts = liveEntry.getStoredEfforts();
			var tempEffort = JSON.stringify( effort );
			var flag = false;

			$.each( storedEfforts, function() {
				var loopedEffort = JSON.stringify( $( this ) );
				if ( loopedEffort == tempEffort ) {
					flag = true;
				}
			} );

			if( flag == false ) {
				return false;
			} else {
				return true;
			};
		},

		/**
		 * Add the Effort data to the "cache" table on the page
		 *
		 */
		addEffortToCache: function() {
			// Initiate DataTable Plugin
			$( '.js-provisional-data-table' ).DataTable();

			$( document ).on( 'click', '.js-add-to-cache', function( event ) {
				event.preventDefault();

				// @TODO build this variable 'thisEffort' from fields on page
				var thisEffort = {"werd": "hello"};
				var storedEfforts = liveEntry.getStoredEfforts();

				if( ! liveEntry.isMatchedEffort( thisEffort ) ) {
					storedEfforts.push( thisEffort );
					liveEntry.saveStoredEfforts( storedEfforts );
				} else {

				}

				return false;
			} );
		},

		/**
		 * Populate the h2 with the eventName
		 *
		 */
		updateEventName: function() {

			$( '.page-title h2' ).text( liveEntry.eventLiveEntryStaticData.eventName );

		},

		/**
		 * Add the Splits data to the select drop down table on the page
		 *
		 */
		buildSplitSelect: function() {

			// Populate select list with actual splits
			var splitItems = '';
			for ( var i = 0; i < liveEntry.eventLiveEntryStaticData.splits.length; i++ ) {
				splitItems += '<option value="' + liveEntry.eventLiveEntryStaticData.splits[ i ].name + '" data-split-id="' + liveEntry.eventLiveEntryStaticData.splits[ i ].id + '" >' + liveEntry.eventLiveEntryStaticData.splits[ i ].name + '</option>';
			}
			$( '#split-select' ).html( splitItems );
		},

		/**
		 * 
		 * @param  integer splitId The station id to switch to
		 */
		changeSplitSlider: function( splitId ) {
			console.log( 'Animating to: ' + splitId );
			// remove all positioning classes
			$( '#js-split-slider' ).removeClass( 'begin end' );
			$( '.js-split-slider-item' ).removeClass( 'active inactive middle begin end' );
			var $selectedSliderItem = $( '.js-split-slider-item[data-split-id="' + splitId + '"]' );

			// Add position classes to the current selected slider item
			$selectedSliderItem.addClass( 'active middle' );
			$selectedSliderItem
				.next( '.js-split-slider-item' ).addClass( 'active end' )
				.next( '.js-split-slider-item' ).addClass( 'inactive end' );
			$selectedSliderItem
				.prev( '.js-split-slider-item' ).addClass( 'active begin' )
				.prev( '.js-split-slider-item' ).addClass( 'inactive begin' );;

			// Check if the slider is at the beginning
			if ( $selectedSliderItem.prev('.js-split-slider-item').length === 0 ) {

				// Add appropriate positioning classes
				$( '#js-split-slider' ).addClass( 'begin' );
			}

			// Check if the slider is at the end
			if ( $selectedSliderItem.next( '.js-split-slider-item' ).length === 0 ) {
				$( '#js-split-slider' ).addClass( 'end' );
			}
		},

		/**
		 * Builds the splits slider based on the splits data
		 *
		 */
		buildSplitSlider: function() {

			// Inject initial html
			var splitSliderItems = '';
			for ( var i = 0; i < liveEntry.eventLiveEntryStaticData.splits.length; i++ ) {
				splitSliderItems += '<div class="split-slider-item js-split-slider-item" data-split-id="' + liveEntry.eventLiveEntryStaticData.splits[ i ].id + '" ><span class="split-slider-item-dot"></span><span class="split-slider-item-name">' + liveEntry.eventLiveEntryStaticData.splits[ i ].name + '</span><span class="split-slider-item-distance">' + liveEntry.eventLiveEntryStaticData.splits[ i ].distance + ' m</span></div>';
			}
			$( '#js-split-slider' ).html( splitSliderItems );

			// Set default states
			$( '.js-split-slider-item' ).eq( 0 ).addClass( 'active middle' );
			$( '.js-split-slider-item' ).eq( 1 ).addClass( 'active end' );
			$( '#js-split-slider' ).addClass( 'begin' );
			$( '#split-select' ).on( 'change', function() {
				var currentItemId = $( '.js-split-slider-item.active.middle' ).attr( 'data-split-id' );
				var selectedItemId = $( 'option:selected' ).attr( 'data-split-id' );
				if ( currentItemId - selectedItemId > 1 ) {
					liveEntry.changeSplitSlider( selectedItemId - 0 + 1 );
				} else if ( selectedItemId - currentItemId > 1 ) {
					liveEntry.changeSplitSlider( selectedItemId - 1 );
				}
				setTimeout( function() {
					$( '#js-split-slider' ).addClass( 'animate' );
					liveEntry.changeSplitSlider( selectedItemId );
					setTimeout( function () {
						$( '#js-split-slider' ).removeClass( 'animate' );
					}, 600 );
				}, 1 );
			} );
		},

		/**
		 * Move a "cached" table row to "top form" section for editing.
		 *
		 */
		editEffort: function() {

			$( '.js-provisional-data-table .js-effort-station-row' ).each( function() {

				var $thisRow = $( this );
				var dataTable = $thisRow.closest( '.js-provisional-data-table' ).DataTable();
				var effort = {};
				effort.uniqueId = $thisRow.attr( 'data-unique-id' );
				effort.eventId = $thisRow.attr( 'data-event-id' );
				effort.splitId = $thisRow.attr( 'data-split-id' );
				effort.effortId = $thisRow.attr( 'data-effort-id' );
				effort.bibNum = $thisRow.attr( 'data-bib-number' );
				effort.effortName = $thisRow.attr( 'data-effort-name' );
				effort.splitName = $thisRow.attr( 'data-split-name' );
				effort.timeIn = $thisRow.attr( 'data-time-in' );
				effort.timeOut = $thisRow.attr( 'data-time-out' );
				effort.pacerIn = $thisRow.attr( 'data-pacer-in' );
				effort.pacerOut = $thisRow.attr( 'data-pacer-out' );

				$thisRow.on( 'click', '.js-edit-effort', function( event ) {
					event.preventDefault();

					// remove table row
					$thisRow.fadeOut( 'fast', function() {
						dataTable.row( $( this ).closest( 'tr' ) ).remove().draw();
					} );

					console.log( effort );


					var repopulateEffortForm = function( effortData ) {
						var storedEfforts = getStoredEfforts();
						console.log( storedEfforts );

						$( document ).find( '#bib-number' ).val( effortData.bibNum );
					}
					repopulateEffortForm( effort );

					// $( '.edit-effort-modal .modal-title .split-name' ).html( effortData.splitName );
					// $( '.edit-effort-modal .js-effort-id-input' ).val( effortData.effortId );
					// $( '.edit-effort-modal .js-split-name-input' ).val( effortData.splitName );
					// $( '.edit-effort-modal .js-bib-number-input' ).val( effortData.bibNum );
					// $( '.edit-effort-modal .js-effort-name-input' ).val( effortData.effortName );
					// $( '.edit-effort-modal .js-time-in-input' ).val( effortData.timeIn );
					// $( '.edit-effort-modal .js-time-out-input' ).val( effortData.timeOut );

					// if( effortData.pacerIn === 'true' ) {
					// 	$( '.edit-effort-modal .js-pacer-in-check' ).prop( 'checked', true );
					// } else {
					// 	$( '.edit-effort-modal .js-pacer-in-check' ).prop( 'checked', false );
					// }

					// if( effortData.pacerOut === 'true' ) {
					// 	$( '.edit-effort-modal .js-pacer-out-check' ).prop( 'checked', true );
					// } else {
					// 	$( '.edit-effort-modal .js-pacer-out-check' ).prop( 'checked', false );
					// }
				} );

				$thisRow.on( 'click', '.js-delete-effort', function( event ) {
					event.preventDefault();
					liveEntry.deleteEffortsRows( $thisRow );
					console.log( 'row removed' );
					return false;
				} );

				$thisRow.on( 'click', '.js-submit-effort', function( event ) {
					event.preventDefault();
					liveEntry.submitEffortRows( $thisRow );
					console.log( 'row submitted' );
					return false;
				} );

			} );

			$( '.js-delete-all-efforts' ).on( 'click', function( event ) {
					event.preventDefault();
					liveEntry.deleteEffortsRows( $( '.js-provisional-data-table .js-effort-station-row' ) );
					console.log( 'rows removed' );
					return false;
			} );

			$( '.js-submit-all-efforts' ).on( 'click', function( event ) {
					event.preventDefault();
					liveEntry.submitEffortRows( $( '.js-provisional-data-table .js-effort-station-row' ) );
					console.log( 'rows submitted' );
					return false;
			} );
		},

		deleteEffortsRows: function( $effortRows ) {
			$effortRows.fadeOut( 'fast', function() {
				var dataTable = $( this ).closest( '.js-provisional-data-table' ).DataTable();
				dataTable.row( $( this ).closest( 'tr' ) ).remove().draw();
			} );
		},

		submitEffortRows: function( $effortRows ) {
			var data = { efforts: [] };
			$effortRows.each( function() {
				var $thisRow = $( this );
				var effort = {};
				effort.uniqueId = $thisRow.attr( 'data-unique-id' );
				effort.eventId = $thisRow.attr( 'data-event-id' );
				effort.splitId = $thisRow.attr( 'data-split-id' );
				effort.effortId = $thisRow.attr( 'data-effort-id' );
				effort.bibNum = $thisRow.attr( 'data-bib-number' );
				effort.effortName = $thisRow.attr( 'data-effort-name' );
				effort.splitName = $thisRow.attr( 'data-split-name' );
				effort.timeIn = $thisRow.attr( 'data-time-in' );
				effort.timeOut = $thisRow.attr( 'data-time-out' );
				effort.pacerIn = $thisRow.attr( 'data-pacer-in' );
				effort.pacerOut = $thisRow.attr( 'data-pacer-out' );
				data.efforts.push( effort );
			} );
			$.get( '/events/' + liveEntry.currentEventId + '/live_entry_ajax_set_split_times', data, function( response ) {
				console.log( response );
			} );
		}
	};

	$( document ).ready( function() {
		liveEntry.init();
	} );
} )( jQuery );
