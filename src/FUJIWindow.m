//
//  FUJIWindow.m
//  Freitag FUJI
//
//  Created by Marc Liyanage on 16.05.05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "FUJIWindow.h"


@implementation FUJIWindow



- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)styleMask backing:(NSBackingStoreType)backingType defer:(BOOL)flag {

	self = [super initWithContentRect:contentRect styleMask:styleMask backing:backingType defer:flag];
	if (!self) return nil;

	keyBuffer = [[NSMutableString alloc] init];
	
	return self;
}


- (void)dealloc {

	[keyBuffer release];
	[super dealloc];
}





- (void)keyDown:(NSEvent *)theEvent {

	if ([theEvent type] != NSKeyDown || ![[self delegate] isAcceptingInput]) {
		[super keyDown:theEvent];
		return;
	}

	if ([[theEvent characters] isEqualToString:@"\r"]) {
		[[self delegate] handleInput:[NSString stringWithString:keyBuffer]];
		[self clearKeyBuffer];
		return;
	}
	
	[keyBuffer appendString:[theEvent characters]];
	
//	int value = [theEvent intValue];
	
/*	NSLog(@"event: %@ / %d / %d", [theEvent characters], [[theEvent characters] length], [theEvent modifierFlags]);
	if ([[theEvent characters] isEqualToString:@"\r"]) {
		NSLog(@"return detected");
	}
*/
	
}


- (BOOL)canBecomeKeyWindow {
	return YES;
}

- (void)clearKeyBuffer {
	[keyBuffer setString:@""];
}


@end
