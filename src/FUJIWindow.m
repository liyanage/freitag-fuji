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
	
	acceptableCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._/"] retain];
	
	return self;
}


- (void)dealloc {
	[keyBuffer release];
	[acceptableCharacters release];
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

	unichar firstInputChar = [[theEvent characters] characterAtIndex:0];

	// turn table special signaling
	unichar specialKeys[] = {NSF1FunctionKey, NSF2FunctionKey, NSF3FunctionKey, 0};
	int i = 0;
	while (specialKeys[i]) {
		if (firstInputChar == specialKeys[i]) {
			[[self delegate] handleInput:[theEvent characters]];
			[self clearKeyBuffer];
			return;
		}
		i++;
	}
	
	if (firstInputChar == (unichar)63289) return;

	if (![acceptableCharacters characterIsMember:[[theEvent characters] characterAtIndex:0]]) {
		[super keyDown:theEvent];
		return;
	}

	[keyBuffer appendString:[theEvent characters]];

/*	NSLog(@"event: %@ / %d / %d", [theEvent characters], [[theEvent characters] length], [theEvent modifierFlags]);
*/
	
}


- (BOOL)canBecomeKeyWindow {
	return YES;
}

- (void)clearKeyBuffer {
	[keyBuffer setString:@""];
}


@end
