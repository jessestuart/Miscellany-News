//
//  RSSArticleParser.h
//  Misc
//
//  Created by Jesse Stuart on 8/14/11.
//  Copyright 2011 Vassar College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSSEntry.h"

@protocol RSSArticleParserDelegate <NSObject>

@required
- (void)articleTextParsedForEntry:(RSSEntry *)entry;

@end

extern NSString * const RSSArticleTextUnavailable;

@interface RSSArticleParser : NSObject
{
    IBOutlet RSSEntry *_entry;
    id <RSSArticleParserDelegate> __unsafe_unretained _delegate;
}

@property (strong) RSSEntry *entry;
@property (unsafe_unretained) NSObject *delegate;

- (id)initWithRSSEntry:(RSSEntry *)entry;
- (void)parseArticleText;

@end