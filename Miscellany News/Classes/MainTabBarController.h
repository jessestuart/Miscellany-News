//
//  MainTabBarController.h
//  Miscellany News
//
//  Created by Jesse Stuart on 9/19/11.
//  Copyright (c) 2011 Vassar College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSSFeedLoader.h"

@class ArticleListController;

@interface MainTabBarController : UIViewController <UITabBarControllerDelegate, RSSFeedLoaderDelegate>
{
    __strong RSSFeedLoader *_feedLoader;
    NSOperationQueue *_queue;
    
    ArticleListController *news;
    ArticleListController *features;
    ArticleListController *opinions;
    ArticleListController *arts;
    ArticleListController *sports;
}

@property (nonatomic, strong) UITabBarController *tabBarController;
@property (nonatomic, strong) NSMutableArray *allEntries;

- (void)refreshFeed;

@end
