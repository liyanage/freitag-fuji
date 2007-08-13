//
//  ServerConfigPerson.m
//  Freitag FUJI
//
//  Created by Marc Liyanage on 16.05.05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "ServerConfigPerson.h"

@implementation ServerConfigPerson

- (id)initWithXMLNode:(NSXMLNode *)node serverConfig:(ServerConfig *)serverConfig {
	
	self = [super initWithXMLNode:node serverConfig:serverConfig];
	if (!self) return nil;
	
	[self setValue:[[[node nodesForXPath:@"Alias/text()" error:nil] objectAtIndex:0] XMLString] forKey:@"alias"];

	NSString *path = [[[node nodesForXPath:@"PathFoto/text()" error:nil] objectAtIndex:0] XMLString];
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?src=%@&width=80&height=80", [serverConfig valueForKey:@"urlGetImage"], path]];
	NSImage *tempImage = [[NSImage alloc] initWithContentsOfURL:url];
	[self setValue:tempImage forKey:@"image"];



//	NSLog(@"url %@", url);
//	NSLog(@"image %@", tempImage);
//	img_get.php?src=bild.jpg&width=100&height=100

	
	return self;
	
}

- (void) dealloc {
	[alias release];
	[image release];
	[super dealloc];
}

@end
