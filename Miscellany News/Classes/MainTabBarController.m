//
//  MainTabBarController.m
//  Miscellany News
//
//  Created by Jesse Stuart on 9/19/11.
//  Copyright (c) 2011 Vassar College. All rights reserved.
//

#import "MainTabBarController.h"
#import "AppDelegate.h"
#import "ArticleListController.h"

@implementation MainTabBarController

- (id)init
{
    if (([super init])) 
    {
//        newsArticlesController = [ArticleListController alloc] 
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
