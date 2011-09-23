//
//  Miscellany_NewsAppDelegate.m
//  Miscellany News
//
//  Created by Jesse Stuart on 8/14/11.
//  Copyright 2011 Vassar College. All rights reserved.
//

#import "AppDelegate.h"

#import "RootViewController.h"
#import "RSSArticleParser.h"
#import "ArticleViewController.h"
#import "MainTabBarController.h"

@implementation AppDelegate

@synthesize queue = _queue,
            feedLoader = _feedLoader,
            entries = _entries,
            window,
            navigationController,
            tabBarController,
            articleViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Create navigation controller & tab bar controller
    navigationController = [[UINavigationController alloc] init];
    tabBarController = [[MainTabBarController alloc] init];
    
    // Nest tab bar controller within navigation controller.
    // Note: this is frowned upon by the HIG, but I believe it makes sense
    // in this context (and besides, the nytimes app does the same thing)
    navigationController.viewControllers = [NSArray arrayWithObject:tabBarController];
    
    window.rootViewController = navigationController;
    [window makeKeyAndVisible];
    
    if (articleViewController == nil) 
    {
        articleViewController = [[ArticleViewController alloc] init];
    }
    
    return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

- (void)awakeFromNib
{
}

@end
