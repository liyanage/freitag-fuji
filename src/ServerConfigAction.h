//
//  ServerConfigAction.h
//  Freitag FUJI
//
//  Created by Marc Liyanage on 16.05.05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ServerConfigItem.h";


@interface ServerConfigAction : ServerConfigItem {

	NSString *barcode, *value, *description;
	int type;
}


- (BOOL)isPrefsAction;
- (BOOL)isCreateJobAction;
- (BOOL)isBagPhotoOffAction;
- (BOOL)isBagPhotoOnAction;
- (BOOL)isType0;
- (BOOL)isType1;
- (BOOL)isTurntableProductPhotoCountAction;
- (unsigned int)turntableProductPhotoCount;

@end
