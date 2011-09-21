//
//  RootViewController.h
//  Miscellany News
//
//  Created by Jesse Stuart on 8/14/11.
//  Copyright 2011 Vassar College. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ASIHTTPRequest.h"
#import "EGORefreshTableHeaderView.h"
#import "RSSFeedLoader.h"

@class ArticleViewController;

@interface RootViewController : UITableViewController <RSSFeedLoaderDelegate, EGORefreshTableHeaderDelegate>
{
    __strong RSSFeedLoader *_feedLoader;
    EGORefreshTableHeaderView *_refreshHeaderView;
    ArticleViewController *_articleViewController;
    NSMutableArray *_allEntries;
    NSOperationQueue *_queue;
    
    BOOL _reloading;
}

@end
