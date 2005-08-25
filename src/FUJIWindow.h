//
//  FUJIWindow.h
//  Freitag FUJI
//
//  Created by Marc Liyanage on 16.05.05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

//@class AppDelegate;

@interface FUJIWindow : NSWindow {

	NSMutableString *keyBuffer;
	NSCharacterSet *acceptableCharacters;

}

- (void)clearKeyBuffer;

@end
