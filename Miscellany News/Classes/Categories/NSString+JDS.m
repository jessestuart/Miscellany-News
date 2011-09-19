//
//  NSString+JDS.m
//  Miscellany News
//
//  Created by Jesse Stuart on 8/17/11.
//  Copyright 2011 Vassar College. All rights reserved.
//

#import "NSString+JDS.h"

@implementation NSString (JDS)

- (NSString *)substringBetweenString:(NSString *)substring1 andString:(NSString *)substring2 regex:(BOOL)regex
{
    NSString *s = [self copy];
    NSRange beginRange, endRange;
    NSUInteger beginIdx, endIdx;
    
    if (regex) 
    {
        beginRange = [s rangeOfString:substring1 options:NSRegularExpressionSearch];
        beginIdx = beginRange.location + beginRange.length;
        endRange = [s rangeOfString:substring2 options:NSRegularExpressionSearch];
        endIdx = endRange.location;
    }
    else
    {
        beginRange = [s rangeOfString:substring1];
        beginIdx = beginRange.location + beginRange.length;
        endRange = [s rangeOfString:substring2];
        endIdx = endRange.location;
    }

    s = [s substringWithRange:NSMakeRange(beginIdx, endIdx-beginIdx)];
    
    return ([s length] > 0) ? s : nil;
}

- (NSString *)stringByRemovingLeadingWhitespace
{
//    if ([self length] > 20) // hack to prevent weird error
//    {
    NSString *s = [self copy];
    NSRange r = [s rangeOfString:@"[a-zA-Z0-9\"]" options:NSRegularExpressionSearch];
    return (r.location != NSNotFound) ? [s substringFromIndex:r.location] : nil;
//    }
//    else return nil;
}

- (NSString *)stringByFlatteningHTML
{
    return [self stringByStrippingMatchingRegex:@"<[^>]+>"];
}

/**
 *  Note: does not validate regex
 */
- (NSString *)stringByStrippingMatchingRegex:(NSString *)regex
{
    NSRange r;
    NSString *s = [self copy];
    while((r = [s rangeOfString:regex options:NSRegularExpressionSearch]).location != NSNotFound)
    {
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    }
    return s;
}

@end
