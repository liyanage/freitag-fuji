//
//  MLCIImageCell.h
//  Freitag FUJI
//
//  Created by Marc Liyanage on 31.07.07.
//  Copyright 2007 Marc Liyanage <http://www.entropy.ch>. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <QuartzCore/QuartzCore.h>

//#define TURNTABLE_PICTURE_CROP_RECT_RATIO 1.25
#define TURNTABLE_PICTURE_CROP_RECT_RATIO 1.25


@interface MLCIImageCell : NSImageCell {
	CIImage *ciImage;
	CIFilter *transitionFilter;
	NSRect cropRect, currentCellFrame;
	NSAnimation *animation;
	NSView *targetView;
	BOOL drawingDone;
}

//- (NSImage *)imageForPath:(NSString *)path;
- (NSRect)cropRectForRect:(CGRect)inputRect Ratio:(float)outputRatio;
- (NSRect)centerScaleSize:(NSSize)size inFrame:(NSRect)frame;
- (void)drawCurrentTransitionState;


@end
