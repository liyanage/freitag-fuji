//
//  MLCIImageCell.m
//  Freitag FUJI
//
//  Created by Marc Liyanage on 31.07.07.
//  Copyright 2007 Marc Liyanage <http://www.entropy.ch>. All rights reserved.
//

#import "MLCIImageCell.h"


@implementation MLCIImageCell


/*

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	if (!ciImage) return;
	currentCellFrame = cellFrame;
	CGRect extent = [ciImage extent];
	NSRect destinationRect = [self centerScaleSize:NSMakeSize(extent.size.width, extent.size.height) inFrame:currentCellFrame];
	[ciImage drawInRect:destinationRect fromRect:*(NSRect *)&extent operation:NSCompositeSourceOver fraction:1.0];
}

*/


- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {

//	if (!ciImage) return;
	if (!transitionFilter) return;
	
	if (animation) {
		if ([animation isAnimating]) return;
		if (drawingDone) {
			[self drawCurrentTransitionState];
			return;
		}
	} else {
		animation = [[NSAnimation alloc] initWithDuration:0.5f animationCurve:NSAnimationEaseOut];
		[animation setFrameRate:30];
		[animation setAnimationBlockingMode:NSAnimationNonblocking]; // try blocking
		[animation setDelegate:self];
		float i;
		for (i = 0.0; i <= 1.0; i += 0.05) [animation addProgressMark:i];
		[animation addProgressMark:1.0];
	}
	
	currentCellFrame = cellFrame;
//	NSLog(@"draw %@", NSStringFromRect(cellFrame));

	[self setValue:controlView forKey:@"targetView"];
	[animation startAnimation];

}



- (void)animation:(NSAnimation*)theAnimation didReachProgressMark:(NSAnimationProgress)progress {

//	NSLog(@"animation callback, progress %f", progress);
//	NSLog(@"rect 2 %@", NSStringFromRect(currentCellFrame));
	
	NSView *view = targetView;
//	NSLog(@"view %@", view);
	[view lockFocus];
	[transitionFilter setValue:[NSNumber numberWithFloat:1.0 - [theAnimation currentValue]] forKey:@"inputTime"];
	[self drawCurrentTransitionState];
	
	[view unlockFocus];
	[[view window] flushWindow];
//	[[self controlView] setNeedsDisplay:YES];

}


- (void)drawCurrentTransitionState {
	CIImage *result = [transitionFilter valueForKey:@"outputImage"];
//	CGRect extent = [ciImage extent];
//	NSLog(@"extent ciimage %@", NSStringFromRect(*(NSRect *)&extent));
	CGRect extent = [result extent];
//	NSLog(@"extent result %@", NSStringFromRect(*(NSRect *)&extent));
	NSRect destinationRect = [self centerScaleSize:NSMakeSize(extent.size.width, extent.size.height) inFrame:currentCellFrame];
	[result drawInRect:destinationRect fromRect:*(NSRect *)&extent operation:NSCompositeSourceOver fraction:1.0];
}



- (void)animationDidEnd:(NSAnimation*)animation {
	drawingDone = YES;
}



- (void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	NSLog(@"highlight");
//	[self setHighlighted:flag];
}




- (void) dealloc {
	[animation release];
//	[ciImage release];
	[transitionFilter release];
	[targetView release];
	[super dealloc];
}



- (NSRect)centerScaleSize:(NSSize)size inFrame:(NSRect)frame {

	NSRect insetRect = NSInsetRect(frame, 10, 10);
//	NSRect insetRect = frame;
	
	float inputRatio = size.width / size.height;
	float outputRatio = insetRect.size.width / insetRect.size.height;
		
	float scale;

	if (inputRatio > outputRatio) {
		scale = insetRect.size.width / size.width;
		float newHeight = size.height * scale;
		insetRect.origin.y = insetRect.origin.y + (insetRect.size.height - newHeight) / 2;
		insetRect.size.height = newHeight;
	} else {
		scale = insetRect.size.height / size.height;
		float newWidth = size.width * scale;
		insetRect.origin.x = insetRect.origin.x + (insetRect.size.width - newWidth) / 2;
		insetRect.size.width = newWidth;
	}

	return insetRect;

}






- (void)setObjectValue:(id <NSCopying>)object {
//	[super setObjectValue:object];
	if (!object) return;

	NSString *path = (NSString *)object;
	CIImage *newCiImage = [CIImage imageWithContentsOfURL:[NSURL fileURLWithPath:path]];
	if (!newCiImage) return;

	drawingDone = NO;

	cropRect = [self cropRectForRect:[newCiImage extent] Ratio:TURNTABLE_PICTURE_CROP_RECT_RATIO];
	float x1 = cropRect.origin.x;
	float y1 = cropRect.origin.y;
	float x2 = cropRect.size.width;
	float y2 = cropRect.size.height;

//	NSLog(@"crop rect %@", NSStringFromRect(cropRect));

	CIVector *inputRectangle = [CIVector vectorWithX:x1 Y:y1 Z:x2 W:y2];

	CIFilter *cropFilter = [CIFilter filterWithName:@"CICrop"];
	[cropFilter setDefaults];
	[cropFilter setValue:newCiImage forKey:@"inputImage"];
	[cropFilter setValue:inputRectangle forKey:@"inputRectangle"];
	CIImage *targetImage = [cropFilter valueForKey: @"outputImage"];

	CIFilter *transform = [CIFilter filterWithName:@"CIAffineTransform"];
	[transform setDefaults];
	[transform setValue:targetImage forKey:@"inputImage"];
	NSAffineTransform *affineTransform = [NSAffineTransform transform];
	[affineTransform scaleXBy:1 yBy:-1];
	[transform setValue:affineTransform forKey:@"inputTransform"];
	targetImage = [transform valueForKey:@"outputImage"];


	CIFilter *constantColor = [CIFilter filterWithName:@"CIConstantColorGenerator"];
	[constantColor setDefaults];
	[constantColor setValue:[CIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0] forKey:@"inputColor"];
	CIImage *colorImage = [constantColor valueForKey:@"outputImage"];


	CGRect extent = [targetImage extent];
	inputRectangle = [CIVector vectorWithX:extent.origin.x Y:extent.origin.y Z:extent.size.width W:extent.size.height];

	CIFilter *transition;

/*	
	transition = [CIFilter filterWithName:@"CICopyMachineTransition"];
	[transition setDefaults];
	[transition setValue:colorImage forKey:@"inputImage"];
	[transition setValue:targetImage forKey:@"inputTargetImage"];
	[transition setValue:inputRectangle forKey:@"inputExtent"];
*/
/*

	transition = [CIFilter filterWithName:@"CIFlashTransition"];
	[transition setDefaults];
	[transition setValue:colorImage forKey:@"inputImage"];
	[transition setValue:targetImage forKey:@"inputTargetImage"];
	[transition setValue:[CIColor colorWithRed:1.0 green:1.0 blue:0.5] forKey:@"inputColor"];
	[transition setValue:[CIVector vectorWithX:extent.size.width/3 Y:-(extent.size.height/3)] forKey:@"inputCenter"];
	[transition setValue:inputRectangle forKey:@"inputExtent"];
*/

	transition = [CIFilter filterWithName:@"CIDissolveTransition"];
	[transition setDefaults];
	[transition setValue:colorImage forKey:@"inputImage"];
	[transition setValue:targetImage forKey:@"inputTargetImage"];

	[self setValue:transition forKey:@"transitionFilter"];

}



/*
- (NSImage *)imageForPath:(NSString *)path {

	CIImage *ciImage = [CIImage imageWithContentsOfURL:[NSURL fileURLWithPath:path]];

	NSRect cropRect = [self cropRectForRect:[ciImage extent] Ratio:TURNTABLE_PICTURE_CROP_RECT_RATIO];
	float x1 = cropRect.origin.x;
	float y1 = cropRect.origin.y;
	float x2 = cropRect.origin.x + cropRect.size.width;
	float y2 = cropRect.origin.y + cropRect.size.height;
	
	CIFilter *cropFilter = [CIFilter filterWithName:@"CICrop"];
	[cropFilter setDefaults];
	[cropFilter setValue:ciImage forKey:@"inputImage"];
	[cropFilter setValue:[CIVector vectorWithX:x1 Y:y1 Z:x2 W:y2] forKey:@"inputRectangle"];

	CIImage *result = [cropFilter valueForKey: @"outputImage"];
	NSCIImageRep *ir = [NSCIImageRep imageRepWithCIImage:result];
	NSImage *image = [[[NSImage alloc] init] autorelease];
//	NSImage *image = [[[NSImage alloc] initWithSize:cropRect.size] autorelease];
	[image addRepresentation:ir];
//	NSLog(@"crop rect %@", NSStringFromRect(cropRect));
//	NSLog(@"image size %@", NSStringFromSize([image size]));
	return image;

//	return [[[NSImage alloc] initByReferencingFile:path] autorelease];
}
*/


- (NSRect)cropRectForRect:(CGRect)inputRect Ratio:(float)outputRatio {

	float width, height, inputRatio = inputRect.size.width / inputRect.size.height;
	NSRect outputRect;

	if (inputRatio > outputRatio) {
		height = inputRect.size.height;
		width = height * outputRatio;
		outputRect.origin.x = (inputRect.size.width - width) / 2;
		outputRect.origin.y = 0;
	} else {
		width = inputRect.size.width;
		height = width / outputRatio;
		outputRect.origin.x = 0;
		outputRect.origin.y = (inputRect.size.height - height) / 2;
	}

	outputRect.size.width = width;
	outputRect.size.height = height;

	return outputRect;
}


/*
- (BOOL)isSelectable {
	NSLog(@"selectable default: %d", [super isSelectable]);
	return NO;
}
*/




@end
