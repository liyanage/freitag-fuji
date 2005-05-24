//
//  ServerConfigColor.h
//  Freitag FUJI
//
//  Created by Marc Liyanage on 16.05.05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ServerConfigItem.h";

@interface ServerConfigColor : ServerConfigItem {

	NSColor *color;
	NSString *hexValue;
	NSImage *image;
	
}



@end
