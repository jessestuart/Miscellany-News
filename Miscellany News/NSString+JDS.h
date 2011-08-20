//
//  NSString+JDS.h
//  Miscellany News
//
//  Created by Jesse Stuart on 8/17/11.
//  Copyright 2011 Vassar College. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (JDS)

- (NSString *)stringByFlatteningHTML;
- (NSString *)stringByRemovingLeadingWhitespace;
- (NSString *)stringByStrippingMatchingRegex:(NSString *)regex;
- (NSString *)stringBetweenPTags;

@end
