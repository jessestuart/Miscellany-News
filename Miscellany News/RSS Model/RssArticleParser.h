//
//  RSSArticleParser.h
//  Misc
//
//  Created by Jesse Stuart on 8/14/11.
//  Copyright 2011 Vassar College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSSEntry.h"

@interface RSSArticleParser : NSObject
{
    IBOutlet RSSEntry *_entry;
}

@property (retain) RSSEntry *entry;

- (id)initWithRSSEntry:(RSSEntry *)entry;
- (void)parseArticleText;

@end
