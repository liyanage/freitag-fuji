/* AppDelegate */

#import <Cocoa/Cocoa.h>
#import <ApplicationServices/ApplicationServices.h>
#import "FUJIWindow.h"
#import "ServerConfig.h"
#import "Constants.h"
#import <CocoaSequenceGrabber/CocoaSequenceGrabber.h>
#import <CocoaSequenceGrabber/CSGCameraSettingsCategory.h>
#import <CURLHandle/CURLHandle+extras.h>


@class FUJIWindow;

@interface AppDelegate : NSObject {

    FUJIWindow *mainWindow;
	
	IBOutlet NSWindow *templateWindow;
	IBOutlet NSBox *boxView;
	IBOutlet NSView *currentPanelView;

	IBOutlet NSPanel *jobScanPanel;
	IBOutlet NSPanel *bagScanPanel;
	IBOutlet NSPanel *prefsPanel;
	IBOutlet NSPanel *initFailedPanel;
	IBOutlet NSPanel *startupPanel;
	IBOutlet NSPanel *modelsPanel;
	IBOutlet NSPanel *peoplePanel;
	IBOutlet NSPanel *capturePanel;
	IBOutlet NSPanel *colorsPanel;
	IBOutlet NSPanel *stylesPanel;
	IBOutlet NSPanel *actionScanPanel;
	IBOutlet NSPanel *actionSuccessPanel;
	IBOutlet NSPanel *submitFailedPanel;
	IBOutlet NSPanel *weightPanel;

	IBOutlet NSMatrix *modelsMatrix;
	IBOutlet NSMatrix *peopleMatrix;
	IBOutlet NSMatrix *colorsMatrix;
	IBOutlet NSMatrix *stylesMatrix;

	IBOutlet NSImageView *personImageView;
	IBOutlet NSImageView *captureImageView;
	IBOutlet NSImageView *colorImageView;

	IBOutlet NSImageView *captureMonitorView;
	
	int appState;
	BOOL acceptingInput, initializing;
	ServerConfig *serverConfig;

	ServerConfigModel *currentModel;
	ServerConfigModel *currentPerson;
	ServerConfigAction *currentAction;
	ServerConfigColor *currentColor;
	ServerConfigColor *currentColor2;
	ServerConfigStyle *currentStyle;
	NSString *lastServerErrorMessage;
	NSString *currentBarcode;
	NSString *currentJobId;
	NSString *tarpWeight;
	NSImage *currentImage;
	
	CSGCamera *camera;
	CSGImage *lastImage;
	
	
}

- (BOOL)appStateAcceptsNonActionBarcode;

- (void)disableInput;
- (void)enableInput;
- (void)handleInput:(NSString *)input;
- (BOOL)isAcceptingInput;
- (BOOL)checkServerResponse:(NSXMLDocument *)responseDoc;
//- (IBAction)toggleAcceptingInput:(id)sender;
- (void)switchToPanelNamed:(NSString *)panelName;

- (IBAction)commitPrefs:(id)sender;
- (IBAction)chooseModel:(id)sender;
- (IBAction)choosePerson:(id)sender;
- (IBAction)chooseColor:(id)sender;
- (IBAction)chooseStyle:(id)sender;
- (IBAction)doRunPrefs:(id)sender;
- (IBAction)runCaptureSettingsDialog:(id)sender;
- (void)setupDefaults;
- (void)runPrefs;
- (void)checkState;
- (void)setState:(int)newState;
- (IBAction)doCheckState:(id)sender;
- (void)runState:(int)newState;
- (void)setupCamera;
- (void)loadServerConfig;
- (void)setupModelsPanel;
- (void)setupPeoplePanel;
- (void)setupColorsPanel;
- (void)setupStylesPanel;
- (void)doInit:(id)object;
- (void)createJob;
- (void)startCapture;
- (void)submitBag;
- (void)submitTarp;
- (void)clearBag;
- (void)clearTarp;
- (void)clearJob;
- (void)submitAction0;
- (void)submitAction1;
- (IBAction)captureFrame:(id)sender;
- (IBAction)enterWeight:(id)sender;
- (IBAction)dismissError:(id)sender;
@end
