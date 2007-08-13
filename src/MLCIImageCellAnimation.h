//
//  MLCIImageCellAnimation.h
//  Freitag FUJI
//
//  Created by Marc Liyanage on 07.08.07.
//  Copyright 2007 Marc Liyanage <http://www.entropy.ch>. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MLCIImageCellAnimation : NSAnimation {
	NSView *targetView;
	NSRect drawRect;
}

@end
