//
//  MLCIImageCellAnimation.m
//  Freitag FUJI
//
//  Created by Marc Liyanage on 07.08.07.
//  Copyright 2007 Marc Liyanage <http://www.entropy.ch>. All rights reserved.
//

#import "MLCIImageCellAnimation.h"


@implementation MLCIImageCellAnimation

- (void)setCurrentProgress:(NSAnimationProgress)progress {
	[super setCurrentProgress:progress];
	NSLog(@"progress: %f", progress);
}


- (void) dealloc {
	[targetView release];
	[super dealloc];
}



@end
