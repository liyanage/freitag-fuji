//
//  ServerConfigColor.m
//  Freitag FUJI
//
//  Created by Marc Liyanage on 16.05.05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "ServerConfigColor.h"


@implementation ServerConfigColor


- (id)initWithXMLNode:(NSXMLNode *)node serverConfig:(ServerConfig *)serverConfig {

	self = [super initWithXMLNode:node serverConfig:serverConfig];
	if (!self) return nil;

	[self setValue:[[[node nodesForXPath:@"HexValue/text()" error:nil] objectAtIndex:0] XMLString] forKey:@"hexValue"];
	
	color = [[NSColor colorWithDeviceRed:[[[[node nodesForXPath:@"r/text()" error:nil] objectAtIndex:0] XMLString] floatValue]
											   green:[[[[node nodesForXPath:@"g/text()" error:nil] objectAtIndex:0] XMLString] floatValue]
												blue:[[[[node nodesForXPath:@"b/text()" error:nil] objectAtIndex:0] XMLString] floatValue]
											   alpha:1] retain];

	image = [[NSImage alloc] initWithSize:NSMakeSize(70,60)];
	[image lockFocus];
	[color set];
	[NSBezierPath fillRect:NSMakeRect(0, 0, 70, 50)];
	[image unlockFocus];
	
	return self;
	
}
	
- (void) dealloc {
	[color release];
	[hexValue release];
	[image release];
	[super dealloc];
}

@end
