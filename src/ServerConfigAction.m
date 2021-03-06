//
//  ServerConfigAction.m
//  Freitag FUJI
//
//  Created by Marc Liyanage on 16.05.05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "ServerConfigAction.h"


@implementation ServerConfigAction

- (id)initWithXMLNode:(NSXMLNode *)node serverConfig:(ServerConfig *)serverConfig {
	
	self = [super initWithXMLNode:node serverConfig:serverConfig];
	if (!self) return nil;
	
	[self setValue:[self stringForXPath:@"Barcode/text()" node:node] forKey:@"barcode"];
	[self setValue:[self stringForXPath:@"Value/text()" node:node] forKey:@"value"];
	[self setValue:[self stringForXPath:@"Description/text()" node:node] forKey:@"description"];
	[self setValue:[self stringForXPath:@"Type/text()" node:node] forKey:@"type"];

//	NSLog(@"action object %@ / %@", barcode, description);

	return self;
	
}


- (void) dealloc {
	[barcode release];
	[value release];
	[description release];
	[super dealloc];
}



- (BOOL)isPrefsAction {
	return [value isEqualToString:@"client_pref"];
}

- (BOOL)isCreateJobAction {
	return [value isEqualToString:@"job_create"];
}

- (BOOL)isBagPhotoOffAction {
	return [value isEqualToString:@"bag_photo_off"];
}

- (BOOL)isBagPhotoOnAction {
	return [value isEqualToString:@"bag_photo_on"];
}

- (BOOL)isTurntableProductPhotoCountAction {
	NSRange found = [value rangeOfString:@"product_photo_count_"];
	return found.location != NSNotFound;
}

- (unsigned int)turntableProductPhotoCount {
	unsigned int count = [[value substringFromIndex:20] intValue];
	NSAssert1(count > 0, @"product photo count not found in value '%@'", value);
	return count;
}



- (BOOL)isType0 {
	return type == 0;
}

- (BOOL)isType1 {
	return type == 1;
}



- (NSString *)description {
	return description;
}



@end
