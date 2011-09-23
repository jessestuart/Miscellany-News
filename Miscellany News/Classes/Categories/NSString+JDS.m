//
//  NSString+JDS.m
//  Miscellany News
//
//  Created by Jesse Stuart on 8/17/11.
//  Copyright 2011 Vassar College. All rights reserved.
//

#import "NSString+JDS.h"

@implementation NSString (JDS)

- (NSString *)stringByTrimmingDuplicateSpaces
{
    NSString *s = [self copy];
    NSRange r;
    while((r = [s rangeOfString:@"  " options:NSRegularExpressionSearch]).location != NSNotFound)
    {
        s = [s stringByReplacingCharactersInRange:r withString:@" "];
    }
    return s;
}

- (NSString *)substringBetweenString:(NSString *)substring1 andString:(NSString *)substring2 regex:(BOOL)regex
{
    NSString *s = self;
    NSRange beginRange, endRange;
    NSUInteger beginIdx, endIdx;
    
    beginRange = [s rangeOfString:substring1 options:(regex ? NSRegularExpressionSearch : NSCaseInsensitiveSearch)];
    beginIdx = beginRange.location + beginRange.length;
    endRange = [s rangeOfString:substring2 options:NSRegularExpressionSearch];
    endIdx = endRange.location;
    
    beginRange = [s rangeOfString:substring1];
    beginIdx = beginRange.location + beginRange.length;
    endRange = [s rangeOfString:substring2];
    endIdx = endRange.location;
    
    // Make sure neither search returned NSNotFound
    if (beginRange.location == NSNotFound || endRange.location == NSNotFound) 
    {
        NSLog(@"error: string not found");
        return nil;
    }
    
    return [s substringWithRange:NSMakeRange(beginIdx, endIdx-beginIdx)];
}

- (NSString *)stringByRemovingLeadingWhitespace
{
    NSString *s = [self copy];
    NSRange r = [s rangeOfString:@"[a-zA-Z0-9\"]" options:NSRegularExpressionSearch];
    return (r.location != NSNotFound) ? [s substringFromIndex:r.location] : s;
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
    NSString *s = [self copy];
    NSRange r;
    while((r = [s rangeOfString:regex options:NSRegularExpressionSearch]).location != NSNotFound)
    {
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    }
    return s;
}

@end
