//
//  Miscellany_NewsAppDelegate.h
//  Miscellany News
//
//  Created by Jesse Stuart on 8/14/11.
//  Copyright 2011 Vassar College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSSFeedLoader.h"

@class ArticleViewController, RootViewController, MainTabBarController;

@interface AppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) RSSFeedLoader *feedLoader;
@property (nonatomic, strong) NSArray *entries;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet UINavigationController *navigationController;
//@property (nonatomic, strong) RootViewController *rootViewController;
@property (nonatomic, strong) IBOutlet MainTabBarController *tabBarController;
@property (nonatomic, strong) ArticleViewController *articleViewController;

//- (void)refreshFeed;

@end
