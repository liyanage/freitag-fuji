//
//  ServerConfigItem.m
//  Freitag FUJI
//
//  Created by Marc Liyanage on 16.05.05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "ServerConfigItem.h"


@implementation ServerConfigItem


- (id)initWithXMLNode:(NSXMLNode *)node serverConfig:(ServerConfig *)serverConfig {

	self = [super init];
	if (!self) return nil;

	// fixme: error checks / match tests
	[self setValue:[self stringForXPath:@"id/text()" node:node] forKey:@"itemId"];
	[self setValue:[self stringForXPath:@"Name/text()" node:node] forKey:@"name"];
	NSLog(@"init config item for %@", [self class]);
	return self;
}


- (void) dealloc {
	[itemId release];
	[name release];
	[super dealloc];
}



- (NSString *)stringForXPath:(NSString *)xpath node:(NSXMLNode *)node {

	NSArray *nodes = [node nodesForXPath:xpath error:nil];
	if (![nodes count]) return nil;
	
	return [[nodes objectAtIndex:0] XMLString];
	
}


@end
