//
//  ServerConfig.m
//  Freitag FUJI
//
//  Created by Marc Liyanage on 16.05.05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "ServerConfig.h"


@implementation ServerConfig

- (id) init {
	self = [super init];
	if (!self) return nil;

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSURL *configURL = [NSURL URLWithString:[defaults objectForKey:@"configurationURL"]];
	doc = [[NSXMLDocument alloc] initWithContentsOfURL:configURL options:0 error:nil];

	if (!doc) {
		NSLog(@"unable to load server config XML from URL '%@'", configURL);
		return nil;
	}

	NSString *successString = [[[doc nodesForXPath:@"/xml/state/text()" error:nil] objectAtIndex:0] XMLString];
	if (![successString isEqualToString:@"success"]) {
		NSLog(@"unable to load server config XML, no 'success' string found");
		return nil;
	}
	
	[self setupURLs];
	
	[self setupColors];
	[self setupStyles];
	[self setupPeople];
	[self setupModels];
	[self setupActions];
	
	return self;
}


- (void) dealloc {
	[doc release];
	[colors release];
	[styles release];
	[people release];
	[models release];
	[actions release];
	[super dealloc];
}


- (void)setupURLs {

	[self setValue:[[[doc nodesForXPath:@"xml/url/item[id = 'action']/url/text()" error:nil] objectAtIndex:0] XMLString] forKey:@"urlAction"];
	[self setValue:[[[doc nodesForXPath:@"xml/url/item[id = 'get_image']/url/text()" error:nil] objectAtIndex:0] XMLString] forKey:@"urlGetImage"];

	//fixme: remove these when xml doc is adjusted
	
//	[self setValue:@"http://mobong.kicks-ass.net/fuji/_communication/action.php" forKey:@"urlAction"];
//	[self setValue:@"http://mobong.kicks-ass.net/fuji/_communication/img_get.php" forKey:@"urlGetImage"];
	
//	img_get.php?src=bild.jpg&width=100&height=100

}




- (void)setupColors {

	colors = [[NSMutableArray alloc] init];

	NSEnumerator *items = [[doc nodesForXPath:@"xml/color/item" error:nil] objectEnumerator];
	
	id item;
	while (item = [items nextObject]) {
		[colors addObject:[[[ServerConfigColor alloc] initWithXMLNode:item serverConfig:self] autorelease]];
	}

}






- (void)setupStyles {

	styles = [[NSMutableArray alloc] init];
	
	NSEnumerator *items = [[doc nodesForXPath:@"xml/style/item" error:nil] objectEnumerator];
	
	id item;
	while (item = [items nextObject]) {
		[styles addObject:[[[ServerConfigStyle alloc] initWithXMLNode:item serverConfig:self] autorelease]];
	}
	
}


- (void)setupPeople {

	people = [[NSMutableArray alloc] init];

	NSEnumerator *items = [[doc nodesForXPath:@"xml/people/item" error:nil] objectEnumerator];
	
	id item;
	while (item = [items nextObject]) {
		[people addObject:[[[ServerConfigPerson alloc] initWithXMLNode:item serverConfig:self] autorelease]];
	}
	
}




- (void)setupModels {

	models = [[NSMutableArray alloc] init];
	
	NSEnumerator *items = [[doc nodesForXPath:@"xml/model/item" error:nil] objectEnumerator];
	
	id item;
	while (item = [items nextObject]) {
		[models addObject:[[[ServerConfigModel alloc] initWithXMLNode:item serverConfig:self] autorelease]];
	}
	
}


- (void)setupActions {
	actions = [[NSMutableArray alloc] init];

	NSEnumerator *items = [[doc nodesForXPath:@"xml/action/item" error:nil] objectEnumerator];
	
	id item;
	while (item = [items nextObject]) {
		[actions addObject:[[[ServerConfigAction alloc] initWithXMLNode:item serverConfig:self] autorelease]];
	}
}


- (ServerConfigAction *)actionForBarcode:(NSString *)barcode {

	NSEnumerator *items = [actions objectEnumerator];
	id item;
	
	while (item = [items nextObject]) {
		if ([[item valueForKey:@"barcode"] isEqualToString:barcode]) {
			return item;
		}
	}
	
	return nil;
}




@end
