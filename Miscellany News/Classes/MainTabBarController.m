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
#import "RSSArticleParser.h"
#import "UIView+JMNoise.h"
#import "MBProgressHUD.h"

@implementation MainTabBarController

@synthesize allEntries = _allEntries,
            tabBarController = _tabBarController;

- (id)init
{
    if ((self = [super init]))
    {
        _queue = [[NSOperationQueue alloc] init];
        [self refreshFeed];
    }
    return self;
}

#pragma mark -
#pragma mark UITabBarController Delegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    int fromIdx = tabBarController.selectedIndex;
    int toIdx = [tabBarController.viewControllers indexOfObject:viewController];
    
    if (fromIdx == toIdx)
    {
        return YES;   
    }
    
    // Get views. controllerIndex is passed in as the controller we want to go to. 
    UIView * fromView = [[tabBarController.viewControllers objectAtIndex:fromIdx] view];
    UIView * toView = [[tabBarController.viewControllers objectAtIndex:toIdx] view];
    
    [UIView transitionFromView:fromView toView:toView duration:0.5
                       options:(fromIdx < toIdx ? UIViewAnimationOptionTransitionCurlUp : UIViewAnimationOptionTransitionCurlDown)
                    completion:^(BOOL finished) {
                        if (finished) {
                            tabBarController.selectedIndex = toIdx;
                        }
                    }];

    return YES;
}

#pragma mark -
#pragma mark Feed loading

- (void)refreshFeed
{
    if(_feedLoader == nil)
    {
        NSURL *miscFeedURL = [NSURL URLWithString:[[[NSBundle mainBundle] infoDictionary] valueForKey:jFeedURL]];
        NSLog(@"feed URL: %@", miscFeedURL);
        _feedLoader = [[RSSFeedLoader alloc] initWithFeedURL:miscFeedURL];
    }
    
    _feedLoader.delegate = self;
    [_feedLoader loadFeed];
}

- (void)feedLoaderDidLoadEntry:(RSSEntry *)entry
{
    RSSArticleParser *articleParser = [[RSSArticleParser alloc] initWithRSSEntry:entry];
//    articleParser.delegate = articleViewController;
    
    [_queue addOperationWithBlock:^{
        [articleParser parseArticleText];
        articleParser.delegate = nil;
    }];
}

- (void)feedLoaderFinishedLoadingEntries:(NSMutableArray *)entries
{
    NSLog(@"feedLoader finished loading entries");
    _allEntries = entries;
    
    NSMutableArray *newsEntries = [NSMutableArray array];
    NSMutableArray *featuresEntries = [NSMutableArray array];
    NSMutableArray *opinionsEntries = [NSMutableArray array];
    NSMutableArray *artsEntries = [NSMutableArray array];
    NSMutableArray *sportsEntries = [NSMutableArray array];
    
    for (RSSEntry *entry in entries)
    {
        switch (entry.categoryID) 
        {
            case MNNewsCategory:
                [newsEntries addObject:entry];
                break;
            case MNFeaturesCategory:
                [featuresEntries addObject:entry];
                break;
            case MNOpinionsCategory:
                [opinionsEntries addObject:entry];
                break;
            case MNArtsCategory:
                [artsEntries addObject:entry];
                break;
            case MNSportsCategory:
                [sportsEntries addObject:entry];
                break;
            default:
                [featuresEntries addObject:entry];
                break;
        }
    }
    
    [news loadEntries:newsEntries];
    [features loadEntries:featuresEntries];
    [opinions loadEntries:opinionsEntries];
    [arts loadEntries:artsEntries];
    [sports loadEntries:sportsEntries];
    
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
}

- (void)feedLoaderDidFailWithError:(NSError *)error
{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
}

#pragma mark View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    self.title = @"The Miscellany News";
    
    // Customize title bar
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.tintColor = [UIColor colorWithRed:0.502 green:0.0 blue:0.0 alpha:1.];
    [navBar applyNoiseWithOpacity:0.5];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Diploma" size:24];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    label.text = self.title;
    self.navigationItem.titleView = label;
    
    /*
     * Create view controllers for each tab
     */
    news = [[ArticleListController alloc] init];
    [news setTabBarItem:[[UITabBarItem alloc] initWithTitle:@"News" image:[UIImage imageNamed:@"166-newspaper.png"] tag:0]];
    
    features = [[ArticleListController alloc] init];
    [features setTabBarItem:[[UITabBarItem alloc] initWithTitle:@"Features" image:[UIImage imageNamed:@"28-star.png"] tag:0]];
    
    opinions = [[ArticleListController alloc] init];
    [opinions setTabBarItem:[[UITabBarItem alloc] initWithTitle:@"Opinions" image:[UIImage imageNamed:@"08-chat.png"] tag:0]];
    
    arts = [[ArticleListController alloc] init];
    [arts setTabBarItem:[[UITabBarItem alloc] initWithTitle:@"Arts" image:[UIImage imageNamed:@"98-palette.png"] tag:0]];
    
    sports = [[ArticleListController alloc] init];
    [sports setTabBarItem:[[UITabBarItem alloc] initWithTitle:@"Sports" image:[UIImage imageNamed:@"89-dumbell.png"] tag:0]];
    
    /*
     * Create the tab bar controller and add all tabs
     */
    _tabBarController = [[UITabBarController alloc] init];
    _tabBarController.view.frame = CGRectMake(0, 0, 320, 460);
    [_tabBarController setViewControllers:[NSArray arrayWithObjects:news, features, opinions, arts, sports, nil]];
    [_tabBarController setDelegate:self];
    [self.view addSubview:_tabBarController.view];
}

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
