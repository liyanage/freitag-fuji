/* AppDelegate */

#import <Cocoa/Cocoa.h>
#import <ApplicationServices/ApplicationServices.h>
#import "FUJIWindow.h"
#import "ServerConfig.h"
#import "Constants.h"
#import <CocoaSequenceGrabber/CocoaSequenceGrabber.h>
#import <CocoaSequenceGrabber/CSGCameraSettingsCategory.h>
#import <CURLHandle/CURLHandle+extras.h>
#import <MLUsbHidWrapper/MLUsbHidDevice.h>
#import <Foundation/NSFileManager.h>
#import <QuartzCore/CIFilter.h>
#import <QuartzCore/CIVector.h>

#define TURNTABLE_THUMBNAIL_COUNT 16
#define TURNTABLE_PICTURE_MINIMUM_AGE_SECONDS 5
#define TURNTABLE_PICTURE_CROP_RECT_RATIO 1.25

@class FUJIWindow;

@interface AppDelegate : NSObject {

    FUJIWindow *mainWindow;
	
	IBOutlet NSWindow *templateWindow;
	IBOutlet NSBox *boxView;
	IBOutlet NSView *currentPanelView;
	IBOutlet NSImageView *logoImageView;

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
	IBOutlet NSPanel *turntablePanel;
	IBOutlet NSPanel *genericErrorPanel;
	
	IBOutlet NSTextField *weightField;

	IBOutlet NSMatrix *modelsMatrix;
	IBOutlet NSMatrix *peopleMatrix;
	IBOutlet NSMatrix *colorsMatrix;
	IBOutlet NSMatrix *stylesMatrix;
	IBOutlet NSBox *turntableThumbnailBox;
	IBOutlet NSMatrix *turntableThumbnailMatrix;

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
	NSString *currentBagCount;
	NSString *lastServerErrorMessage;
	NSString *genericErrorPanelMessage;
	NSString *currentBarcode;
	NSString *currentJobId;
	NSString *tarpWeight;
	NSCharacterSet *weightNumberCharacterSkipSet;

	NSImage *currentImage;
	
	CSGCamera *camera;
	CSGImage *lastImage;
	
	NSDate *timestamp;
	NSMutableDictionary *turntableImages;
	
}

- (BOOL)appStateAcceptsNonActionBarcode;

- (void)disableInput;
- (void)enableInput;
- (void)handleInput:(NSString *)input;
- (BOOL)isAcceptingInput;
- (BOOL)checkServerResponse:(NSXMLDocument *)responseDoc;
- (NSString *)stringForXpath:(NSString *)xpath inDocument:(NSXMLDocument *)doc;
//- (IBAction)toggleAcceptingInput:(id)sender;
- (void)switchToPanelNamed:(NSString *)panelName;
- (void)showTurntablePreviews;
- (void)hideTurntablePreviews;

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
- (void)runGenericErrorForMessage:(NSString *)message;
- (BOOL)setupCamera;
- (BOOL)loadServerConfig;
- (void)runStartState;
- (void)setStartState;
- (void)setupModelsPanel;
- (void)setupPeoplePanel;
- (void)setupColorsPanel;
- (void)setupStylesPanel;
- (void)doInit:(id)object;
- (void)createJob;
- (void)startCapture;
- (void)signalTurntableStart;
- (void)processTurntableSignal;
- (void)uploadTurntablePictures;
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
- (BOOL)checkAndPreparePictureDirectory;
- (NSString *)pictureDirectoryPath;
- (NSString *)turntablePictureFilenameList;
- (BOOL)pictureDirectoryExists;
- (void)checkTurntablePictures;
- (void)checkTurntablePicturesTimer;
- (void)clearTurntablePictures;
- (NSTimeInterval)updateTurntablePictures;
- (NSImage *)imageForPath:(NSString *)path;
- (NSRect)cropRectForRect:(CGRect)inputRect Ratio:(float)outputRatio;

@end
