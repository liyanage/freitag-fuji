//
//  MLFloatFormatter.m
//  Freitag FUJI
//
//  Created by Marc Liyanage on 02.07.05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "MLFloatFormatter.h"

// lifted from http://www.cocoabuilder.com/archive/message/cocoa/2004/8/11/114277


@implementation MLFloatFormatter

- (BOOL)getObjectValue:(id *)obj forString:(NSString *)string errorDescription:(NSString  **)error {
    *obj = string;
    return(YES);
}

- (NSString *)stringForObjectValue:(id)anObject {
    if([anObject isKindOfClass:[NSString class]])
    {
       return(anObject);
    }
    else
    {
       return(nil);
    }
}

- (BOOL)isPartialStringValid:(NSString *)partialString newEditingString:(NSString **)newString errorDescription:(NSString **)error {
   NSRange foundRange;
   
   // allow numbers, decimal point
   NSCharacterSet *disallowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
   foundRange = [partialString rangeOfCharacterFromSet:disallowedCharacters];
   if(foundRange.location != NSNotFound) {
       *error = @"Input contains one or more non-numeric characters.";
        NSBeep();
        return(NO);
   }
   
   
   // disallow more than one period
   UInt8 i;
   BOOL firstPeriod = NO;
   for(i = 0; i < [partialString length]; ++i) {
       if([[partialString substringWithRange:NSMakeRange(i, 1)] isEqualTo:@"."]) {
           if(firstPeriod) {
               *error = @"Multiple periods are not allowed.";
               NSBeep();
               return(NO);
           }
           
           firstPeriod = YES;
       }
   }

    *newString = partialString;
    return(YES);
}

@end
