//
//  NSString+JDS.m
//  Miscellany News
//
//  Created by Jesse Stuart on 8/17/11.
//  Copyright 2011 Vassar College. All rights reserved.
//

#import "NSString+JDS.h"

@implementation NSString (JDS)

- (NSString *)stringByRemovingLeadingWhitespace
{
    if ([self length] > 20) 
    {
        NSString *s = [[self copy] autorelease];
        NSRange r = [s rangeOfString:@"[a-zA-Z0-9\"]" options:NSRegularExpressionSearch];
        return (r.location == 0) ? [s substringFromIndex:r.location] : [s substringFromIndex:r.location-1];
    }
    else return nil;
}

- (NSString *)stringByFlatteningHTML
{
    NSRange r;
    NSString *s = [[self copy] autorelease];
    while((r = [s rangeOfString:@"<[^>]+>|\t" options:NSRegularExpressionSearch]).location != NSNotFound)
    {
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    }
    return s;
}

@end
