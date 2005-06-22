//
//  CSGCameraSettingsCategory.h
//  CocoaSequenceGrabber
//
//  Created by Marc Liyanage on 21.06.05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <CocoaSequenceGrabber/CSGCamera.h>


@interface CSGCamera (Settings)

- (void)runSettingsDialog;
- (NSData *)getSettings;
- (void)setSettings:(NSData *)settingsData;


@end

