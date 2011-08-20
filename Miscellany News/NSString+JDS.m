//
//  NSString+JDS.m
//  Miscellany News
//
//  Created by Jesse Stuart on 8/17/11.
//  Copyright 2011 Vassar College. All rights reserved.
//

#import "NSString+JDS.h"

@implementation NSString (JDS)

- (NSString *)stringBetweenPTags
{
    NSString *s = [[self copy] autorelease];
    NSRange begin = [s rangeOfString:@"<p>"];
    NSUInteger beginIdx = begin.location + begin.length + 1;
    NSUInteger endIdx = [s rangeOfString:@"</p>"].location;
    return [s substringWithRange:NSMakeRange(beginIdx, endIdx-beginIdx)];
}

- (NSString *)stringByRemovingLeadingWhitespace
{
    if ([self length] > 20) 
    {
        NSString *s = [[self copy] autorelease];
        NSRange r = [s rangeOfString:@"[a-zA-Z0-9\"]" options:NSRegularExpressionSearch];
        return [s substringFromIndex:r.location];
    }
    else return nil;
}

- (NSString *)stringByFlatteningHTML
{
    NSRange r;
    NSString *s = [[self copy] autorelease];
    while((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
    {
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    }
    return s;
}

/**
 *  Note: does not validate regex
 */
- (NSString *)stringByStrippingMatchingRegex:(NSString *)regex
{
    NSRange r;
    NSString *s = [[self copy] autorelease];
    while((r = [s rangeOfString:regex options:NSRegularExpressionSearch]).location != NSNotFound)
    {
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    }
    return s;
}

@end
