//
//  RootViewController.m
//  Miscellany News
//
//  Created by Jesse Stuart on 8/14/11.
//  Copyright 2011 Vassar College. All rights reserved.
//

#import "RootViewController.h"
#import "ArticleViewController.h"
/* RSS */
#import "RSSEntry.h"
#import "RSSArticleParser.h"
/* Sorting unsorted entries */
#import "NSArray+Extras.h" 
/* XML parsing */
#import "TouchXML.h"
#import "CXMLElement+JDS.h"
/* View */
#import "MBProgressHUD.h"
#import "UIView+JMNoise.h"
#import "UIImage+ProportionalFill.h"
/* Fetching and caching images */
#import "EGOImageLoader.h"
/* Miscellaneous convenience methods */
#import "NSString+JDS.h"
#import "NSString+HTML.h"


@interface RootViewController ()
- (void)sortEntries:(NSMutableArray *)unsortedEntries;
- (void)parseArticleTextForEntry:(RSSEntry *)entry;
@end

@implementation RootViewController

@synthesize fetchedResultsController = __fetchedResultsController,
            managedObjectContext = __managedObjectContext;

#pragma mark -
#pragma mark Feed parsing

/**
 *  Initialize an HTTP request for the RSS feed data
 */
- (void)refreshFeed
{
    // Pull feed URL from info plist, initialize ASIHTTP request, and add to queue
    NSURL *miscFeedURL = [NSURL URLWithString:[[[NSBundle mainBundle] infoDictionary] valueForKey:feedURL]];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:miscFeedURL];
    request.delegate = self;
    [_queue addOperation:request];
}

/**
 *  ASIHTTPRequestDelegate callback. Display a "Failed to retrieve feed" alert view.
 */
- (void)requestFailed:(ASIHTTPRequest *)request
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network error" 
                                                    message:@"Failed to retrieve feed." 
                                                   delegate:nil 
                                          cancelButtonTitle:@"Close" 
                                          otherButtonTitles:nil];
    [alert show];
}

/**
 *  ASIHTTPRequestDelegate callback. 
 */
- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Autorelease pool
//    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    // Working array for unsorted RSS entries
    NSMutableArray *unsortedEntries = [[NSMutableArray alloc] init];
    
    // Initialize XML document with feed data
    NSError *error = nil;
    CXMLDocument *document = [[CXMLDocument alloc] initWithData:[request responseData] options:0 error:&error];
    JSAssert(error == nil, @"Error creating document from feed");
    
    // We can use the channel element to get to all of the RSS items
    CXMLElement *channel = [[[document rootElement] elementsForName:@"channel"] lastObject];
    
    // Initialize date formatter. We'll use this to convert the pubDate into an NSDate object
    NSDateFormatter *pubDateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *USEnglishLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [pubDateFormatter setLocale:USEnglishLocale];
    [pubDateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
    
    // Recurse over all the RSS items in the feed
    for (CXMLElement *item in [channel elementsForName:@"item"])
    {
        @autoreleasepool 
        {
            
            /* NOTE: lot of weird hackery in here to deal with the messy RSS */
            NSString *title = [[item elementForName:@"title"] stringByFlatteningHTML];
            NSString *author = [[[[item elementForName:@"author"] substringFromIndex:1] 
                                 stringByReplacingOccurrencesOfString:@" and " withString:@" & "]
                                stringByReplacingOccurrencesOfString:@"the " withString:@""];
            NSString *link = [item elementForName:@"link"];
            NSString *summary = [[[[item elementForName:@"description"] stringByRemovingLeadingWhitespace] stringByFlatteningHTML] stringByDecodingHTMLEntities];
            NSDate *pubDate = [pubDateFormatter dateFromString:[item elementForName:@"pubDate"]];
            NSString *guid = [item elementForName:@"guid"];
            NSString *category = [item elementForName:@"category"];
            
            NSLog(@"category: %@", category);
            
            // Allocate a new RSSEntry from feed info & add to unsorted entries
            RSSEntry *entry = [[RSSEntry alloc] initWithTitle:title link:link author:author summary:summary pubDate:pubDate guid:guid category:category];
            JSAssert(entry != nil, @"Error allocating entry");
            [unsortedEntries addObject:entry];
            
            // Parse article text in background
            [self parseArticleTextForEntry:entry];
            // Fetch thumbnail
            entry.thumbnailURL = [[[[item elementsForName:@"thumbnail"] lastObject] attributeForName:@"url"] stringValue];
            entry.thumbnail = [[[EGOImageLoader sharedImageLoader] imageForURL:[NSURL URLWithString:entry.thumbnailURL] shouldLoadWithObserver:nil] imageCroppedToFitSize:CGSizeMake(70, 70)];   
        }
    }
    
    [self sortEntries:unsortedEntries];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
//    [pool drain];
}

- (void)parseArticleTextForEntry:(RSSEntry *)entry
{
    RSSArticleParser *articleParser = [[RSSArticleParser alloc] initWithRSSEntry:entry];
    articleParser.delegate = _articleViewController;
    
    [_queue addOperationWithBlock:^{
        [articleParser parseArticleText];
        articleParser.delegate = nil;
    }];
}

- (void)sortEntries:(NSMutableArray *)unsortedEntries
{
    for (RSSEntry *entry in unsortedEntries) 
    {
        // Sort by date
        int insertIdx = [_allEntries indexForInsertingObject:entry
                                            sortedUsingBlock:^(id a, id b) {
                                                RSSEntry *entry1 = (RSSEntry *) a;
                                                RSSEntry *entry2 = (RSSEntry *) b;
                                                return [entry1.pubDate compare:entry2.pubDate];
                                            }];
        // Add to array
        [_allEntries insertObject:entry atIndex:insertIdx];
        
        // Add to table view
        NSArray *idxPaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:insertIdx inSection:0]];
        [self.tableView insertRowsAtIndexPaths:idxPaths withRowAnimation:UITableViewRowAnimationRight];
    }
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"The Miscellany News";
    
    // Customize title bar
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.tintColor = [UIColor colorWithRed:0.502 green:0.0 blue:0.0 alpha:1.];
    [navBar applyNoiseWithOpacity:0.5];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Palatino-Bold" size:20.0];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    label.text = self.title;
    self.navigationItem.titleView = label;
    
    // Customize TableView
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    self.tableView.rowHeight = 80;
    
    // Allocate ivars
    _allEntries = [[NSMutableArray alloc] init];
    _queue = [[NSOperationQueue alloc] init];

    // Show activity indicator
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    /*
     * Load ArticleViewController so it can be set as RSSArticleParser's delegate
     */
    if (_articleViewController == nil) 
    {
        _articleViewController = [[ArticleViewController alloc] initWithNibName:@"ArticleViewController" bundle:[NSBundle mainBundle]];
    }
    
    /*
     * Load EGORefreshTableHeaderView
     */
    if (_refreshHeaderView == nil) 
    {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height) arrowImageName:@"blackArrow.png" textColor:[UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0]];
        view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
	}
    
    // Update the last update date
    [_refreshHeaderView refreshLastUpdatedDate];
    
    // Begin parsing RSS feed
    [self refreshFeed];
}

#pragma mark -
#pragma mark Memory management


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _refreshHeaderView = nil;
    _articleViewController = nil;
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

#pragma mark Table view configuration
// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    return [[self.fetchedResultsController sections] count];
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_allEntries count];
    /* @TODO core data
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
     */
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
                                       reuseIdentifier:CellIdentifier];
    }

    // Configure the cell.
    RSSEntry *entry = [_allEntries objectAtIndex:indexPath.row];
    
    cell.textLabel.font = [UIFont fontWithName:@"Palatino-Bold" size:16.0];
    cell.textLabel.text = entry.title;
    cell.textLabel.numberOfLines = 2;
    
//    cell.imageView.image = entry.thumbnail;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:entry.thumbnail];
    cell.accessoryView = imageView;

    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    cell.detailTextLabel.text = entry.summary;
    cell.detailTextLabel.numberOfLines = 2;
    
//    if (indexPath.row == 0) {
//        cell.imageView.image = [UIImage imageNamed:@"2623635910.JPG"];
//    } else if (indexPath.row == 2) {
//        cell.imageView.image = [UIImage imageNamed:@"221749802.jpg"];
//    }
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"weird method");
//    if (editingStyle == UITableViewCellEditingStyleDelete)
//    {
//        // Delete the managed object for the given index path
//        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
//        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
//        
//        // Save the context.
//        NSError *error = nil;
//        if (![context save:&error])
//        {
//            /*
//             Replace this implementation with code to handle the error appropriately.
//             
//             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
//             */
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
//        }
//    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Load article view if unloaded
    if (_articleViewController == nil) {
        _articleViewController = [[ArticleViewController alloc] initWithNibName:@"ArticleViewController" bundle:[NSBundle mainBundle]];
    }

    _articleViewController.entry = [_allEntries objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:_articleViewController animated:YES];
    
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
	*/
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
	
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
	
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

@end
