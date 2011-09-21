//
//  RSSFeedLoader.h
//  Miscellany News
//
//  Created by Jesse Stuart on 9/19/11.
//  Copyright (c) 2011 Vassar College. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RSSFeedLoaderDelegate <NSObject>
@optional
- (void)feedLoaderDidStart;

@required
- (void)feedLoaderDidFailWithError:(NSError *)error;
- (void)feedLoaderDidLoadEntries:(NSArray *)entries;
@end

@interface RSSFeedLoader : NSObject

@property (strong) NSArray *entries;

- (id)initWithFeedURL:(NSURL *)feedURL;

@end
