//
//  ServerConfigItem.h
//  Freitag FUJI
//
//  Created by Marc Liyanage on 16.05.05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ServerConfig;

@interface ServerConfigItem : NSObject {
	
	NSString *itemId, *name;
	
}

- (id)initWithXMLNode:(NSXMLNode *)node serverConfig:(ServerConfig *)serverConfig;

//+ (id)itemWithXMLNode:(NSXMLNode *)node;

- (NSString *)stringForXPath:(NSString *)xpath node:(NSXMLNode *)node;


@end
