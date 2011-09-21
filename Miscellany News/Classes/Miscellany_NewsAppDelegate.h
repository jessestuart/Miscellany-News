//
//  Miscellany_NewsAppDelegate.h
//  Miscellany News
//
//  Created by Jesse Stuart on 8/14/11.
//  Copyright 2011 Vassar College. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Miscellany_NewsAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, strong) NSArray *entries;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet UINavigationController *navigationController;
//@property (nonatomic, strong) IBOutlet UITabBarController *tabBarController;

@end
