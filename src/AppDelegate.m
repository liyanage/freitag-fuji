#import "AppDelegate.h"

@implementation AppDelegate

- (void)awakeFromNib {
	weightNumberCharacterSkipSet = [[[NSCharacterSet characterSetWithCharactersInString:@"01234567890."] invertedSet] retain];
	[self setValue:[NSNumber numberWithBool:YES] forKey:@"shouldCaptureBagPhoto"];
	[self setValue:[NSNumber numberWithInt:TURNTABLE_THUMBNAIL_COUNT] forKey:@"turntableProductPhotoCount"];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    NSRect screenRect = [[NSScreen mainScreen] frame];

	NSString *resolution = [[NSUserDefaults standardUserDefaults] valueForKey:@"resolution"];
	if (resolution) {
		NSArray *items = [resolution componentsSeparatedByString:@"x"];
		if ([items count] == 2) {
			screenRect = NSMakeRect(0, 0, [[items objectAtIndex:0] floatValue], [[items objectAtIndex:1] floatValue]);
		} else {
			NSLog(@"resolution parameter must be of format XXXxYYY");
		}
	}

	mainWindow = [[FUJIWindow alloc] initWithContentRect:screenRect
		styleMask:NSTexturedBackgroundWindowMask
		backing:NSBackingStoreBuffered
		defer:NO screen:[NSScreen mainScreen]];
	
	[mainWindow setDelegate:self];

#ifndef DEBUG
	[mainWindow setMovableByWindowBackground:NO];
	CGDisplayCapture(kCGDirectMainDisplay);
	[mainWindow setLevel:CGShieldingWindowLevel()];
#endif
	
    [mainWindow makeKeyAndOrderFront:nil];
	[mainWindow setContentView:[templateWindow contentView]];

	[self runState:UNINITIALIZED];

}


- (void)dealloc {
	[mainWindow release];
	[serverConfig release];
	[currentBarcode release];
	[currentBagCount release];
	[camera release];
	[lastServerErrorMessage release];
	[genericErrorPanelMessage release];
	[weightNumberCharacterSkipSet release];
	[timestamp release];
	[turntableImages release];
	[super dealloc];
}


- (void)applicationWillTerminate:(NSNotification *)notification {
	[mainWindow orderOut:self];
	CGDisplayRelease(kCGDirectMainDisplay);
}


# pragma mark Initialization

+ (void)initialize {
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
		@"http://mobong.kicks-ass.net/fuji/_communication/action.php?action=client_init", @"configurationURL",
		[NSNumber numberWithInt:1], @"clientId",
		@"YES", @"debugMode",
		nil];

	[[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:appDefaults];
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
}


- (void)setupModelsPanel {
	NSArray *cells = [modelsMatrix cells];
	NSArray *models = [serverConfig valueForKey:@"models"];
	
	int i = 0;
	for (i = 0; i < [cells count]; i++) {
		id cell = [cells objectAtIndex:i];
		if (i >= [models count]) {
			[cell setEnabled:NO];
			[cell setTitle:@""];
			continue;
		}
		id model = [models objectAtIndex:i];
		[cell setTitle:[model valueForKey:@"name"]];
		[cell setRepresentedObject:model];
	}
}


- (void)setupPeoplePanel {
	NSArray *cells = [peopleMatrix cells];
	NSArray *people = [serverConfig valueForKey:@"people"];
	
	int i = 0;
	for (i = 0; i < [cells count]; i++) {
		id cell = [cells objectAtIndex:i];
		if (i >= [people count]) {
			[cell setEnabled:NO];
			[cell setTitle:@""];
			continue;
		}
		id person = [people objectAtIndex:i];
		[cell setTitle:[person valueForKey:@"alias"]];
		[cell setImage:[person valueForKey:@"image"]];
		[cell setRepresentedObject:person];
	}
}


- (void)setupColorsPanel {
	NSArray *cells = [colorsMatrix cells];
	NSArray *colors = [serverConfig valueForKey:@"colors"];
	
	int i = 0;
	for (i = 0; i < [cells count]; i++) {
		id cell = [cells objectAtIndex:i];
		if (i >= [colors count]) {
			[cell setEnabled:NO];
			[cell setTitle:@""];
			continue;
		}
		id color = [colors objectAtIndex:i];
		[cell setTitle:[color valueForKey:@"name"]];
		[cell setImage:[color valueForKey:@"image"]];
		[cell setRepresentedObject:color];
	}
}


- (void)setupStylesPanel {
	NSArray *cells = [stylesMatrix cells];
	NSArray *styles = [serverConfig valueForKey:@"styles"];
	
	int i = 0;
	for (i = 0; i < [cells count]; i++) {
		id cell = [cells objectAtIndex:i];
		if (i >= [styles count]) {
			[cell setEnabled:NO];
			[cell setTitle:@""];
			continue;
		}
		id style = [styles objectAtIndex:i];
		[cell setTitle:[style valueForKey:@"name"]];
		[cell setRepresentedObject:style];
	}	
}


- (BOOL)setupCamera {
	if (camera) return YES;
	camera = [[CSGCamera alloc] init];
	if (!camera) return NO;
	[camera setDelegate:self];

	NSData *cameraSettings = [[NSUserDefaults standardUserDefaults] valueForKey:@"cameraSettings"];
	if (cameraSettings) {
		[camera setSettings:cameraSettings];
	}
	return YES;
}


- (BOOL)loadServerConfig {
	[self setValue:[[[ServerConfig alloc] init] autorelease] forKey:@"serverConfig"];
	if (!serverConfig) return NO;
	return YES;
}


- (void)runStartState {
	if ([serverConfig isClientMode:CLIENT_MODE_BAG]) {
		[self runState:SCAN_JOB_BARCODE];
	} else if ([serverConfig isClientMode:CLIENT_MODE_TURNTABLE]) {
		[self runState:SCAN_TURNTABLE_BARCODE];
	} else {
		[self runState:SCAN_TARP_BARCODE];
	}
}


- (void)setStartState {
	if ([serverConfig isClientMode:CLIENT_MODE_BAG]) {
		[self setState:SCAN_JOB_BARCODE];
	} else if ([serverConfig isClientMode:CLIENT_MODE_TURNTABLE]) {
		[self setState:SCAN_TURNTABLE_BARCODE];
	} else {
		[self setState:SCAN_TARP_BARCODE];
	}
}



- (NSString *)pictureDirectoryPath {
	return [NSHomeDirectory() stringByAppendingPathComponent:@"Pictures"];
}


- (BOOL)pictureDirectoryExists {
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *dirPath = [self pictureDirectoryPath];
	BOOL isDir;
	BOOL exists = [fm fileExistsAtPath:dirPath isDirectory:&isDir];
	if (isDir && exists) return YES;
	NSLog(@"'Pictures' directory does not exist at expected location '%@'", dirPath);
	return NO;
}


- (BOOL)checkAndPreparePictureDirectory {
	return [self pictureDirectoryExists];
}



#pragma mark Barcode (and other keyboard) input handling

- (void)handleInput:(NSString *)input {

	/* If we're currently displaying an error message, any input
	 * dismisses the error
	 * and resets the app to the start state */
	if (appState == GENERIC_ERROR) {
		[self dismissError:self];
		return;
	}

	if ([input length] > 0 && [input characterAtIndex:0] == NSF1FunctionKey) {
		if (appState != WAIT_FOR_TURNTABLE_SIGNAL) {
			NSLog(@"F1 key seen while not in WAIT_FOR_TURNTABLE_SIGNAL state, ignoring...");
			return;
		};
		NSLog(@"16 photos");
		[self setTurntableProductPhotoCount:16];
		[self runState:RECEIVED_TURNTABLE_SIGNAL];
		return;
	}
	

	if ([input length] > 0 && [input characterAtIndex:0] == NSF2FunctionKey) {
		if (appState != WAIT_FOR_TURNTABLE_SIGNAL) {
			NSLog(@"F2 key seen while not in WAIT_FOR_TURNTABLE_SIGNAL state, ignoring...");
			return;
		};
		NSLog(@"8 photos");
		[self setTurntableProductPhotoCount:8];
		[self runState:RECEIVED_TURNTABLE_SIGNAL];
		return;
	}
	

	if (appState == WAIT_FOR_TURNTABLE_SIGNAL) {
		NSLog(@"Non-F1 keyboard input received while in WAIT_FOR_TURNTABLE_SIGNAL state, returning to start state");
		[self clearTurntablePictures];
		[self runStartState];
		return;
	};


	if (![input length]) {
		NSLog(@"Empty input string received, ignoring...");
		return;
	}

	
	/* store the barcode for whatever purpose we might need it later on */
	[self setValue:input forKey:@"currentBarcode"];

	/* check for action barcodes */
	ServerConfigAction *action = [serverConfig actionForBarcode:input];
	if (action) {
		[self setValue:action forKey:@"currentAction"];
		if ([action isPrefsAction]) {
			[self runState:RUN_PREFS];
		} else if ([action isTurntableProductPhotoCountAction]) {
			[self setTurntableProductPhotoCount:[action turntableProductPhotoCount]];
		} else if ([action isCreateJobAction]) {
			[self runState:SCAN_JOB_BARCODE];
		} else if ([action isBagPhotoOffAction]) {
			[self setValue:[NSNumber numberWithBool:NO] forKey:@"shouldCaptureBagPhoto"];
		} else if ([action isBagPhotoOnAction]) {
			[self setValue:[NSNumber numberWithBool:YES] forKey:@"shouldCaptureBagPhoto"];
		} else if ([action isType0]) {
			[self runState:SUBMIT_ACTION_TYPE0];
		} else if ([action isType1]) {
			[self runState:SCAN_ACTION_PARAM_BARCODE];
		}
		return;
	} else if (![self appStateAcceptsNonActionBarcode]) {
		NSLog(@"rejecting non-action barcode %@", input);
		return;
	}

	
	/* No action, must be a data or action parameter barcode */
	
	if (appState == SCAN_JOB_BARCODE) {
		[self runState:PICK_MODEL];
	} else if (appState == SCAN_BAG_BARCODE) {
		[self runState:shouldCaptureBagPhoto ? CAMERA_CAPTURE : PICK_COLOR];
	} else if (appState == SCAN_ACTION_PARAM_BARCODE) {
		[self runState:SUBMIT_ACTION_TYPE1];
	} else if (appState == SCAN_TARP_BARCODE) {
		[self runState:CAMERA_CAPTURE];
	} else if (appState == SCAN_TURNTABLE_BARCODE) {
		[self runState:SIGNAL_TURNTABLE_START];
	}
	
}


- (void)disableInput {
	acceptingInput = NO;
}


- (void)enableInput {
	[mainWindow clearKeyBuffer];
	acceptingInput = YES;
}


- (BOOL)appStateAcceptsNonActionBarcode {
	switch (appState) {
		case SCAN_TARP_BARCODE:
		case SCAN_JOB_BARCODE:
		case SCAN_BAG_BARCODE:
		case SCAN_TURNTABLE_BARCODE:
		case SCAN_ACTION_PARAM_BARCODE:
		case CAMERA_CAPTURE:
		case PICK_COLOR:
		case PICK_STYLE:
			return YES;
		
		default:
			return NO;
	}
}


- (BOOL)isAcceptingInput {
	return acceptingInput;
}



#pragma mark Delegate method implementations


#pragma mark Panel switching

- (void)switchToPanelNamed:(NSString *)panelName {

//	NSLog(@"switching to panel '%@'", panelName);
	
	id newPanel = [self valueForKey:[NSString stringWithFormat:@"%@Panel", panelName]];
	id newView = [newPanel contentView];
	id oldView = currentPanelView;
	if (newView == oldView) return;

	// fixme: retain count keeps on going up. not leaking as we're
	// reusing the views all the time until app termination, but not quite clean either.
	
//	NSLog(@"1 old content view %@, retaincount %d", oldView, [oldView retainCount]);	
//	NSLog(@"2 new content view %@, retaincount %d", newView, [newView retainCount]);	

//	NSRect screenRect = [[NSScreen mainScreen] frame];
//	[newPanel setFrame:screenRect display:YES];

//	NSString *rect = NSStringFromRect(screenRect);
//	NSLog(@"panel for string '%@': %@, rect: %@", panelName, panel, rect);

//	NSLog(@"3 old content view %@, retaincount %d", oldView, [oldView retainCount]);	
//	NSLog(@"4 new content view %@, retaincount %d", newView, [newView retainCount]);	
	NSRect oldRect = [currentPanelView frame];
    [oldView retain];
//	[mainWindow setContentView:newView];
	[boxView replaceSubview:oldView with:newView];
	currentPanelView = newView;
	[newView setFrame:oldRect];
//	[newView setNeedsDisplay:YES];
//	[mainWindow update];
//	[[NSApplication sharedApplication] updateWindows];
//	
//	NSLog(@"5 old content view %@, retaincount %d", oldView, [oldView retainCount]);	
//	NSLog(@"6 new content view %@, retaincount %d", newView, [newView retainCount]);	
	
//	NSLog(@"test config url %@", [[NSUserDefaults standardUserDefaults] valueForKey:@"configURL"]);
	
}


- (void)showTurntablePreviews {
	[boxView setHidden:YES];
	[logoImageView setHidden:YES];
	[turntableThumbnailBox setHidden:NO];
}


- (void)hideTurntablePreviews {
	[turntableThumbnailBox setHidden:YES];
	[boxView setHidden:NO];
	[logoImageView setHidden:NO];
}


#pragma mark App state management

- (void)runState:(int)newState {
#ifdef DEBUG
	NSLog(@"State transition from %d to %d", appState, newState);
#endif
	[self setState:newState];
	[self checkState];
}


- (void)checkState {
//	NSLog(@"checkState: %d", appState);
	
	switch (appState) {
		
		case UNINITIALIZED:
			[self switchToPanelNamed:@"startup"];
			[self performSelector:@selector(doInit:) withObject:nil afterDelay:0.1];
			break;
			
		case INITFAILED:
			[self enableInput];
			[self switchToPanelNamed:@"initFailed"];
			appState = UNINITIALIZED;
			break;
			
		case RUN_PREFS:
			[self runPrefs];
			break;
			
		case RUNNING_PREFS:
			[self commitPrefs:nil];
			break;
			
		case SCAN_JOB_BARCODE:
			[self enableInput];
			[self clearJob];
			[self switchToPanelNamed:@"jobScan"];
			break;
			
		case PICK_MODEL:
			[self enableInput];
			[self switchToPanelNamed:@"models"];
			break;
			
		case PICK_PERSON:
			[self enableInput];
			[self switchToPanelNamed:@"people"];
			break;
			
		case CREATE_JOB:
			[self createJob];
			break;
			
		case SCAN_BAG_BARCODE:
		case SCAN_TURNTABLE_BARCODE:
			[self enableInput];
			[self switchToPanelNamed:@"bagScan"];
			break;
			
		case CAMERA_CAPTURE:
			// if this disableInput goes away, need to ensure capture stop.
			// might need to change action of capture button to doCheckState,
			// and check for the capturing state here.
			[self disableInput];
			
			[self switchToPanelNamed:@"capture"];
			[self startCapture];
			break;
			
		case PICK_COLOR:
		case PICK_COLOR2:
			[self enableInput];
			[self switchToPanelNamed:@"colors"];
			break;
			
		case PICK_STYLE:
		case PICK_QUALITY:
			[self enableInput];
			[self switchToPanelNamed:@"styles"];
			break;

		case ENTER_WEIGHT:
			[self enableInput];
			[self switchToPanelNamed:@"weight"];
			[templateWindow makeFirstResponder:weightField];
			break;

		case SUBMIT_BAG:
			[self disableInput];
			[self submitBag];
			break;

		case SUBMIT_ACTION_TYPE0:
			[self disableInput];
			[self submitAction0];
			break;
			
		case SUBMIT_TARP:
			[self disableInput];
			[self submitTarp];
			break;

		case SCAN_ACTION_PARAM_BARCODE:
			[self enableInput];
			[self switchToPanelNamed:@"actionScan"];
			break;
			
		case SUBMIT_ACTION_TYPE1:
			[self disableInput];
			[self submitAction1];
			break;

		case SUBMIT_JOB_FAILED:
		case SUBMIT_BAG_FAILED:
		case SUBMIT_ACTION_FAILED:
		case SUBMIT_TARP_FAILED:
			[self switchToPanelNamed:@"submitFailed"];
			break;

		case GENERIC_ERROR:
			[self enableInput];
			[self switchToPanelNamed:@"genericError"];
			break;

		case CONFIRM_ACTION_SUCCESS:
			[self switchToPanelNamed:@"actionSuccess"];
			[self setStartState];
			break;

		case SCAN_TARP_BARCODE:
			[self enableInput];
			[self clearJob];
			[self switchToPanelNamed:@"jobScan"];
			break;

		case SIGNAL_TURNTABLE_START:
			[self signalTurntableStart];
			break;

		case WAIT_FOR_TURNTABLE_SIGNAL:
			[self enableInput];
			[self checkTurntablePictures];
			[self showTurntablePreviews];
//			[self switchToPanelNamed:@"turntable"];
			break;
			
		case RECEIVED_TURNTABLE_SIGNAL:
			[self disableInput];
			[self processTurntableSignal];
			break;
			
		default:
			NSLog(@"unknown state %d!", appState);
			break;
	}
}


- (void)setState:(int)newState {
	appState = newState;
}


- (void)runGenericErrorForMessage:(NSString *)message {
	[self setValue:message forKey:@"genericErrorPanelMessage"];
	[self runState:GENERIC_ERROR];
}


#pragma mark App state handlers

- (void)doInit:(id)object {
	[self disableInput];
	[self setValue:[NSNumber numberWithBool:YES] forKey:@"initializing"];
	if (![self loadServerConfig]) {
		[self runState:INITFAILED];
		return;
	}
	
	if ([serverConfig isClientMode:CLIENT_MODE_BAG] || [serverConfig isClientMode:CLIENT_MODE_TARP]) {
		// These modes need a QuickTime video source
		[self setupModelsPanel];
		[self setupPeoplePanel];
		[self setupColorsPanel];
		[self setupStylesPanel];
		if (![self setupCamera]) {
			NSLog(@"Unable to initialize camera");
			[self runState:INITFAILED];
			return;
		}
	} else if ([serverConfig isClientMode:CLIENT_MODE_TURNTABLE]) {
		if (![self checkAndPreparePictureDirectory]) {
			NSLog(@"Unable to set up Picture directory");
			[self runState:INITFAILED];
			return;
		}
	} else {
		NSLog(@"Unknown client mode %d", [serverConfig clientMode]);
	}

	[self setValue:[NSNumber numberWithBool:NO] forKey:@"initializing"];
	[self runStartState];
}


- (void)createJob {
	NSString *urlString = [NSString stringWithFormat:@"%@?action=job_create&param=%@&fotographer=%@&model=%@&client=%@",
		[serverConfig valueForKey:@"urlAction"],
		currentBarcode,
		[currentPerson valueForKey:@"itemId"],
		[currentModel valueForKey:@"itemId"],
		[[NSUserDefaults standardUserDefaults] valueForKey:@"clientId"]
	];

	NSLog(@"url: %@", urlString);
	NSURL *requestURL = [NSURL URLWithString:urlString];
	NSXMLDocument *responseDoc = [[[NSXMLDocument alloc] initWithContentsOfURL:requestURL options:0 error:nil] autorelease];

	if (![self checkServerResponse:responseDoc]) {
		[self runState:SUBMIT_JOB_FAILED];
		return;
	}

	[self setValue:@"1234" forKey:@"currentJobId"];
	[self setValue:[[[responseDoc nodesForXPath:@"xml/result/text()" error:nil] objectAtIndex:0] XMLString] forKey:@"currentJobId"];
	[self runState:SCAN_BAG_BARCODE];
	
}


- (void)runPrefs {

	[self disableInput];
	[self switchToPanelNamed:@"prefs"];
	[self setState:RUNNING_PREFS];
	
}


- (void)startCapture {
//	NSSize captureSize = [captureMonitorView frame];
//	NSLog(@"%@", NSStringFromRect([captureMonitorView frame]));
//	NSLog(@"%@", NSStringFromRect([captureMonitorView bounds]));
	[camera startWithSize:NSMakeSize(640, 480)];
}


- (void)camera:(CSGCamera *)aCamera didReceiveFrame:(CSGImage *)aFrame {
	[captureMonitorView setImage:aFrame];
	[self setValue:aFrame forKey:@"lastImage"];
}


- (void)signalTurntableStart {
	[self setValue:[NSDate date] forKey:@"timestamp"];

	NSArray *devices = [MLUsbHidDevice findDevicesForForUsagePage:0x01 usage:0x06];
	NSAssert([devices count] > 0, @"No matching USB devices found");

	unsigned int i, count = [devices count];
	for (i = 0; i < count; i++) {
		MLUsbHidDevice *device = [devices objectAtIndex:i];
		BOOL result = [device setElementValue:1 forUsagePage:8 usage:2];
		if (!result) {
			NSLog(@"Unable to signal turntable (on) on USB device %d of %d", i + 1, count);
		}
	}

	[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];

	for (i = 0; i < count; i++) {
		MLUsbHidDevice *device = [devices objectAtIndex:i];
		BOOL result = [device setElementValue:0 forUsagePage:8 usage:2];
		if (!result) {
			NSLog(@"Unable to signal turntable (off) on USB device %d of %d", i + 1, count);
		}
	}

	[self runState:WAIT_FOR_TURNTABLE_SIGNAL];
}


- (void)processTurntableSignal {
	NSTimeInterval age = -[self updateTurntablePictures];
	NSTimeInterval minimumAge = (NSTimeInterval)TURNTABLE_PICTURE_MINIMUM_AGE_SECONDS;
	if (age < minimumAge) {
		NSLog(@"age of last image file is below threshold (%f < %f), waiting...", age, minimumAge);
		[self performSelector:@selector(processTurntableSignal) withObject:nil afterDelay:1.0];
		return;
	}
	
	int count = [turntableImages count];
	if (count != turntableProductPhotoCount) {
		[self clearTurntablePictures];
		[self runGenericErrorForMessage:[NSString stringWithFormat:@"Es wurden %d statt %d Bilder empfangen", count, turntableProductPhotoCount]];
		return;
	}

	[self uploadTurntablePictures];
}


- (void)uploadTurntablePictures {
	id tempDirPath = NSTemporaryDirectory();
	NSString *transferScriptPath = [[NSBundle mainBundle] pathForResource:@"freitag-fuji-transfer" ofType:@"pl"];
	NSString *barcode = [self valueForKey:@"currentBarcode"];
	NSString *perlLibPath = [[NSBundle mainBundle] pathForResource:@"perl-lib-lwp" ofType:@""];

	NSMutableArray *args = [NSMutableArray array];
	// first the script path as passed to the Perl interpreter
	[args addObject:[NSString stringWithFormat:@"-I%@", perlLibPath]];     
	[args addObject:transferScriptPath];     
	// add the remaining args as key/value pairs

	[args addObject:@"capture_dir_path"];
	[args addObject:[self pictureDirectoryPath]];

	[args addObject:@"capture_files"];
	[args addObject:[self turntablePictureFilenameList]];

	[args addObject:@"temp_dir_path"];
	[args addObject:tempDirPath];
	[args addObject:@"barcode"];
	[args addObject:barcode];
	[args addObject:@"action_url"];
	[args addObject:[serverConfig valueForKey:@"urlAction"]];

//	NSLog(@"/usr/bin/perl %@", [args componentsJoinedByString:@" "]);
	
	NSTask *task = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/perl" arguments:args];
	NSLog(@"transfer script launched with pid %d for job %@", [task processIdentifier], barcode);

	[self clearTurntablePictures];
	[self runStartState];
}


- (NSString *)turntablePictureFilenameList {
	NSMutableArray *filenameArray = [NSMutableArray array];
	unsigned int i, count = [[turntableImages allKeys] count];
	for (i = 0; i < count; i++) {
		NSString *path = [[turntableImages allKeys] objectAtIndex:i];
		[filenameArray addObject:[path lastPathComponent]];
	}
	return [filenameArray componentsJoinedByString:@","];
}


- (void)checkTurntablePictures {
	if (appState != WAIT_FOR_TURNTABLE_SIGNAL) return;
	[self clearTurntablePictures];
	[self setValue:[NSMutableDictionary dictionary] forKey:@"turntableImages"];
	[self performSelector:@selector(checkTurntablePicturesTimer) withObject:nil afterDelay:1.0];
}


- (void)checkTurntablePicturesTimer {
	if (appState != WAIT_FOR_TURNTABLE_SIGNAL) return;
	[self updateTurntablePictures];
	[self performSelector:@selector(checkTurntablePicturesTimer) withObject:nil afterDelay:1.0];
}


- (void)clearTurntablePictures {
	[self hideTurntablePreviews];
	[self setValue:nil forKey:@"turntableImages"];
	NSArray *cells = [turntableThumbnailMatrix cells];
	unsigned int i, count = [cells count];
	for (i = 0; i < count; i++) {
		MLCIImageCell *cell = [cells objectAtIndex:i];
		[cell setImage:nil];
	}
}


- (NSTimeInterval)updateTurntablePictures {
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *picDirPath = [self pictureDirectoryPath];
	NSArray *things = [fm directoryContentsAtPath:picDirPath];
	
	unsigned int i, count = [things count];
	NSDate *latestModTime = [NSDate distantPast];
	for (i = 0; i < count; i++) {
		NSString *filename = [things objectAtIndex:i];
		NSString *fullPath = [[picDirPath stringByAppendingString:@"/"] stringByAppendingString:filename];
		if (![[filename lowercaseString] hasSuffix:@".jpg"]) continue;
		NSDate *modTime = [[fm fileAttributesAtPath:fullPath traverseLink:YES] fileModificationDate];
		if (!([modTime compare:timestamp] == NSOrderedDescending)) continue;
		latestModTime = [modTime laterDate:latestModTime];
		if ([turntableImages objectForKey:fullPath]) continue;
		
//		NSImage *image = [self imageForPath:fullPath];
//		[turntableImages setObject:image forKey:fullPath];
		[turntableImages setObject:[NSNull null] forKey:fullPath];

		unsigned count = [turntableImages count];
		if (count > turntableProductPhotoCount) continue;

		unsigned index = count - 1;
//		NSImageCell *ic = [[turntableThumbnailMatrix cells] objectAtIndex:index];
//		[ic setObjectValue:image];
		MLCIImageCell *ic = [[turntableThumbnailMatrix cells] objectAtIndex:index];
		[ic setObjectValue:fullPath];
		[turntableThumbnailMatrix setNeedsDisplay:YES];
		
//		NSLog(@"path %@", fullPath);
	}

	NSTimeInterval lastFileAge = [latestModTime timeIntervalSinceNow];
//	NSLog(@"lastFileAge %f", lastFileAge);
	return lastFileAge;
}


- (void)submitBag {
	CURLHandle *curl = (CURLHandle *)[CURLHandle cachedHandleForURL:[NSURL URLWithString:[serverConfig valueForKey:@"urlAction"]]];
	
	id imagePart = @"ignore";
	if (shouldCaptureBagPhoto) {
		NSData *jpegImage = [[[currentImage representations] objectAtIndex:0] representationUsingType:NSJPEGFileType properties:nil];
		imagePart = [NSDictionary dictionaryWithObjectsAndKeys:jpegImage, @"data", @"dummy.jpg", @"filename", @"image/jpeg", @"mimeType", nil];
	}

	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
		@"bag_add", @"action",
		currentBarcode, @"param",
		[[NSUserDefaults standardUserDefaults] stringForKey:@"clientId"], @"client",
		currentJobId, @"job",
		[currentColor valueForKey:@"itemId"], @"color",
		[currentStyle valueForKey:@"itemId"], @"style",
		imagePart, @"foto",
		nil
	];

	[curl setMultipartPostDictionary:params];
	NSData *response = [curl resourceData];
	if (!response) {
		NSLog(@"submitBag: Unable to submit, null CURLHandle response, barcode = %@, curlError = %@", currentBarcode, [curl curlError]);
		[self runState:SUBMIT_BAG_FAILED];
		return;
	}

	NSXMLDocument *responseDoc = [[[NSXMLDocument alloc] initWithData:response options:0 error:nil] autorelease];

	[self clearBag];

	if (!responseDoc || ![self checkServerResponse:responseDoc]) {
		[self runState:SUBMIT_BAG_FAILED];
		return;
	}

	[self runState:SCAN_BAG_BARCODE];
}


- (void)submitTarp {
	CURLHandle *curl = (CURLHandle *)[CURLHandle cachedHandleForURL:[NSURL URLWithString:[serverConfig valueForKey:@"urlAction"]]];

	NSData *jpegImage = [[[currentImage representations] objectAtIndex:0] representationUsingType:NSJPEGFileType properties:nil];
//	[jpegImage writeToFile:@"/tmp/bag.jpg" atomically:YES];
	NSDictionary *imagePart = [NSDictionary dictionaryWithObjectsAndKeys:jpegImage, @"data", @"dummy.jpg", @"filename", @"image/jpeg", @"mimeType", nil];
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
		@"tarp_add", @"action",
		currentBarcode, @"param",
		[[NSUserDefaults standardUserDefaults] stringForKey:@"clientId"], @"client",
		[currentColor valueForKey:@"itemId"], @"color0",
		[currentColor2 valueForKey:@"itemId"], @"color1",
		[currentStyle valueForKey:@"itemId"], @"style",
		tarpWeight, @"weight",
		imagePart, @"foto",
		nil];

	[curl setMultipartPostDictionary:params];
	NSData *response = [curl resourceData];
	if (!response) {
		NSLog(@"submitTarp: Unable to submit, null CURLHandle response, barcode = %@, curlError = %@", currentBarcode, [curl curlError]);
		[self runState:SUBMIT_TARP_FAILED];
		return;
	}
	NSXMLDocument *responseDoc = [[[NSXMLDocument alloc] initWithData:response options:0 error:nil] autorelease];

	[self clearTarp];

	if (![self checkServerResponse:responseDoc]) {
		[self runState:SUBMIT_TARP_FAILED];
		return;
	}

	[self runState:SCAN_TARP_BARCODE];
}


- (void)submitAction0 {
	NSString *urlString = [NSString stringWithFormat:@"%@?action=%@&client=%@",
		[serverConfig valueForKey:@"urlAction"],
		[currentAction valueForKey:@"value"],
		[[NSUserDefaults standardUserDefaults] valueForKey:@"clientId"]
	];
//	NSLog(@"url: %@", urlString);
	NSURL *requestURL = [NSURL URLWithString:urlString];
	NSXMLDocument *responseDoc = [[[NSXMLDocument alloc] initWithContentsOfURL:requestURL options:0 error:nil] autorelease];
	
	if ([self checkServerResponse:responseDoc]) {
		[self runState:CONFIRM_ACTION_SUCCESS];
		return;
	}
	
	[self runState:SUBMIT_ACTION_FAILED];
}


- (void)submitAction1 {
	NSString *urlString = [NSString stringWithFormat:@"%@?action=%@&param=%@&client=%@",
		[serverConfig valueForKey:@"urlAction"],
		[currentAction valueForKey:@"value"],
		currentBarcode,
		[[NSUserDefaults standardUserDefaults] valueForKey:@"clientId"]
		];
//	NSLog(@"url: %@", urlString);
	NSURL *requestURL = [NSURL URLWithString:urlString];
	NSXMLDocument *responseDoc = [[[NSXMLDocument alloc] initWithContentsOfURL:requestURL options:0 error:nil] autorelease];
	
	if ([self checkServerResponse:responseDoc]) {
		[self runState:CONFIRM_ACTION_SUCCESS];
		return;
	}
	
	[self runState:SUBMIT_ACTION_FAILED];
}


- (BOOL)checkServerResponse:(NSXMLDocument *)responseDoc {
	NSString *state = [self stringForXpath:@"xml/state/text()" inDocument:responseDoc];
	NSString *result = [self stringForXpath:@"xml/result/text()" inDocument:responseDoc];
	NSString *count = [self stringForXpath:@"xml/count/text()" inDocument:responseDoc];

	if (! state) {
		[self setValue:@"(Unbekannter Fehler)" forKey:@"lastServerErrorMessage"];
		return NO;
	}

	if (result) {
		[self setValue:result forKey:@"lastServerErrorMessage"];
	} else {
		[self setValue:@"(Unbekannter Fehler)" forKey:@"lastServerErrorMessage"];
	}

	if (count) {
		[self setValue:count forKey:@"currentBagCount"];
	} else {
		[self setValue:nil forKey:@"currentBagCount"];
	}

	if ([state isEqualToString:@"success"]) {
		[self setValue:@"" forKey:@"lastServerErrorMessage"];
		return YES;
	}

	NSLog(@"checkServerResponse: Failure server response %@", [responseDoc XMLData]);

	return NO;
}


- (NSString *)stringForXpath:(NSString *)xpath inDocument:(NSXMLDocument *)doc {
	NSArray *nodes = [doc nodesForXPath:xpath error:nil];
	if ([nodes count] < 1) return nil;
	return [[nodes objectAtIndex:0] XMLString];
}


- (void)clearBag {
	[self setValue:nil forKey:@"currentBarcode"];
	[self setValue:nil forKey:@"currentColor"];
	[self setValue:nil forKey:@"currentStyle"];
	[self setValue:nil forKey:@"currentImage"];
}


- (void)clearTarp {
	[self setValue:nil forKey:@"currentBarcode"];
	[self setValue:nil forKey:@"currentColor"];
	[self setValue:nil forKey:@"currentColor2"];
	[self setValue:nil forKey:@"currentStyle"];
	[self setValue:nil forKey:@"currentImage"];
	[self setValue:nil forKey:@"tarpWeight"];
}


- (void)clearJob {
	[self clearBag];
	[self setValue:nil forKey:@"currentModel"];
	[self setValue:nil forKey:@"currentPerson"];
	[self setValue:nil forKey:@"currentAction"];
	[self setValue:nil forKey:@"currentJobId"];
}


- (void)setTurntableProductPhotoCount:(unsigned int)count {
	NSLog(@"turntable product photo count: %d", count);
	turntableProductPhotoCount = count;
}


#pragma mark IBActions

- (IBAction)commitPrefs:(id)sender {
//	NSLog(@"commit prefs");
	[self runState:UNINITIALIZED];
}


- (IBAction)chooseModel:(id)sender {
	id cell = [sender selectedCell];
	[self setValue:[cell representedObject] forKey:@"currentModel"];
	[self runState:PICK_PERSON];
}


- (IBAction)choosePerson:(id)sender {
	id cell = [sender selectedCell];
	[self setValue:[cell representedObject] forKey:@"currentPerson"];
	[self runState:CREATE_JOB];
}


- (IBAction)captureFrame:(id)sender {
	[camera stop];
	[self setValue:lastImage forKey:@"currentImage"];
	[self runState:PICK_COLOR];
}


- (IBAction)enterWeight:(id)sender {
	[self runState:SUBMIT_TARP];
}


- (IBAction)chooseColor:(id)sender {
	id cell = [sender selectedCell];

	NSString *colorKey = appState == PICK_COLOR ? @"currentColor" : @"currentColor2";
	[self setValue:[cell representedObject] forKey:colorKey];

	if ([serverConfig isClientMode:CLIENT_MODE_BAG]) {
		[self runState:PICK_STYLE];
	} else if (appState == PICK_COLOR) {
		[self runState:PICK_COLOR2];
	} else {
		[self runState:PICK_QUALITY];
	}
}


- (IBAction)chooseStyle:(id)sender {
	id cell = [sender selectedCell];

	[self setValue:[cell representedObject] forKey:@"currentStyle"];

	if (appState == PICK_STYLE) {
		[self runState:SUBMIT_BAG];
	} else {
//		NSLog(@"chooseStyle: switching to state ENTER_WEIGHT, app state %d, client mode %d", appState, [serverConfig clientMode]);
		[self runState:ENTER_WEIGHT];
	}
}


- (IBAction)runCaptureSettingsDialog:(id)sender {
#ifndef DEBUG
	CGDisplayRelease(kCGDirectMainDisplay);
	[mainWindow setLevel:NSNormalWindowLevel];
#endif

	[camera runSettingsDialog];

	NSData *settings = [camera getSettings];
	[[NSUserDefaults standardUserDefaults] setValue:settings forKey:@"cameraSettings"];

#ifndef DEBUG
	CGDisplayCapture(kCGDirectMainDisplay);
	[mainWindow setLevel:CGShieldingWindowLevel()];
#endif
}


- (IBAction)doRunPrefs:(id)sender {
	[self runState:RUN_PREFS];
}


- (IBAction)dismissError:(id)sender {
	switch (appState) {
		
		case SUBMIT_BAG_FAILED:
			[self runState:SCAN_BAG_BARCODE];
			break;

		case SUBMIT_TARP_FAILED:
			[self runState:SCAN_TARP_BARCODE];
			break;

		case SUBMIT_JOB_FAILED:
		case SUBMIT_ACTION_FAILED:
		case GENERIC_ERROR:
		default:
			[self runStartState];
			break;
	}
}


- (IBAction)doCheckState:(id)sender {
	[self checkState];
}


@end
