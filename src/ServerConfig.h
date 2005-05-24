//
//  ServerConfig.h
//  Freitag FUJI
//
//  Created by Marc Liyanage on 16.05.05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ServerConfigColor.h"
#import "ServerConfigStyle.h"
#import "ServerConfigPerson.h"
#import "ServerConfigModel.h"
#import "ServerConfigAction.h"


@interface ServerConfig : NSObject {
	NSXMLDocument *doc;
	NSMutableArray *colors;
	NSMutableArray *styles;
	NSMutableArray *people;
	NSMutableArray *models;
	NSMutableArray *actions;

	NSString *urlAction;
	NSString *urlGetImage;
}

- (void)setupURLs;

- (void)setupColors;
- (void)setupStyles;
- (void)setupPeople;
- (void)setupModels;
- (void)setupActions;

- (ServerConfigAction *)actionForBarcode:(NSString *)barcode;

@end
