
enum app_states {
	UNINITIALIZED = 1,
	INITFAILED,                  //  2
	INITIALIZED,                 //  3
	RUN_PREFS,                   //  4
	RUNNING_PREFS,               //  5
	SCAN_JOB_BARCODE,            //  6
	PICK_MODEL,                  //  7
	PICK_PERSON,                 //  8
	SCAN_BAG_BARCODE,            //  9
	CAMERA_CAPTURE,              // 10
	PICK_COLOR,                  // 11
	PICK_COLOR2,                 // 12
	PICK_STYLE,                  // 13
	PICK_QUALITY,                // 14
	ENTER_WEIGHT,                // 15
	SCAN_ACTION_PARAM_BARCODE,   // 16
	CREATE_JOB,                  // 17
	SUBMIT_BAG,                  // 18
	SUBMIT_ACTION_TYPE0,         // 19
	SUBMIT_ACTION_TYPE1,         // 20
	SUBMIT_JOB_FAILED,           // 21
	SUBMIT_BAG_FAILED,           // 22
	SUBMIT_TARP_FAILED,          // 23
	SUBMIT_ACTION_FAILED,        // 24
	SUBMIT_TARP,                 // 25
	CONFIRM_ACTION_SUCCESS,      // 26
	
	SCAN_TARP_BARCODE,           // 27
	SCAN_TURNTABLE_BARCODE,      // 28
	SIGNAL_TURNTABLE_START,      // 29
	WAIT_FOR_TURNTABLE_SIGNAL,   // 30
	RECEIVED_TURNTABLE_SIGNAL,   // 31

	GENERIC_ERROR                // 32
	
};

enum client_modes {
	CLIENT_MODE_BAG = 0,         // Product image video capture workstation
	CLIENT_MODE_TARP = 1,        // Tarp image video capture workstation
	CLIENT_MODE_TURNTABLE = 2    // Turntable multi-image DSLR capture workstation
};

