//
//  RSSFeedLoader.h
//  Miscellany News
//
//  Created by Jesse Stuart on 9/19/11.
//  Copyright (c) 2011 Vassar College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@class RSSEntry;

@interface RSSFeedLoader : NSObject <ASIHTTPRequestDelegate>

@property (unsafe_unretained) id delegate;
@property (strong) NSOperationQueue *queue;
@property (strong) NSURL *feedURL;

- (id)initWithFeedURL:(NSURL *)feedURL;
- (void)refreshFeed;

@end

// Protocol definition
@protocol RSSFeedLoaderDelegate <NSObject>
@optional
- (void)feedLoaderDidStart;
- (void)feedLoaderDidFailWithError:(NSError *)error;
- (void)feedLoaderDidLoadEntry:(RSSEntry *)entry;
@required
- (void)feedLoaderFinishedLoadingEntries:(NSMutableArray *)entries;
@end
