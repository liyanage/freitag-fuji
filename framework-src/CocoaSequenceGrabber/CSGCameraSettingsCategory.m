//
//  CSGCameraSettingsCategory.m
//  CocoaSequenceGrabber
//
//  Created by Marc Liyanage on 21.06.05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "CSGCameraSettingsCategory.h"


@implementation CSGCamera (Settings)

- (void)runSettingsDialog {

	OSErr theErr;
	theErr = SGSettingsDialog(component, channel, 0, NULL, seqGrabSettingsPreviewOnly, NULL, (long)NULL);
	NSLog(@"runSettingsDialog() theErr: %d", theErr);
}


- (NSData *)getSettings {

	NSData *settingsData = nil;
	OSErr theErr;
	
	UserData ud;
	theErr = SGGetChannelSettings(component, channel, &ud, 0);
//	theErr = SGGetSettings(component, &ud, 0);

	Handle hSettings;
	hSettings = NewHandle(0);
	theErr = MemError();
	if (noErr == theErr) {

		theErr = PutUserDataIntoHandle(ud, hSettings);

		if (noErr == theErr) {
			HLock(hSettings);
			settingsData = [NSData dataWithBytes:(UInt8 *)*hSettings length:GetHandleSize(hSettings)];
			
		} else {
			NSLog(@"PutUserDataIntoHandle() error");
		}
		
		DisposeHandle(hSettings);

	} else {
		NSLog(@"NewHandle() error");
	}

	return settingsData;

}


- (void)setSettings:(NSData *)settingsData {

	OSErr theErr;
	UserData ud = NULL;
	Handle hSettings = NULL;

    theErr = PtrToHand([settingsData bytes], &hSettings, [settingsData length]);

	if (hSettings) {

		theErr = NewUserDataFromHandle(hSettings, &ud);

		if (ud) {
			//theErr = SGSetSettings(component, ud, 0);
			theErr = SGSetChannelSettings(component, channel, ud, 0);
		} else {
			NSLog(@"NewUserDataFromHandle error");
		}
		
		DisposeHandle(hSettings);

	} else {
			NSLog(@"PtrToHand error");
	}

}


@end


