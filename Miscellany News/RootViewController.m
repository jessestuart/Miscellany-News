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


@interface RootViewController ()
- (void)sortEntries:(NSMutableArray *)unsortedEntries;
- (void)parseArticleTextForEntry:(RSSEntry *)entry;
@end

@implementation RootViewController

//@synthesize unsortedEntries;
@synthesize allEntries = _allEntries;
@synthesize queue = _queue;
@synthesize articleViewController = _articleViewController;

@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;

#pragma mark Feed parsing

/**
 *  Initialize an HTTP request for the RSS feed data
 */
- (void)refreshFeed
{
    // Pull feed URL from info plist, initialize ASIHTTP request, and add to queue
    NSURL *feedURL = [NSURL URLWithString:[[[NSBundle mainBundle] infoDictionary] valueForKey:kFeedURL]];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:feedURL];
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
    [alert release], alert = nil;
}

/**
 *  ASIHTTPRequestDelegate callback. 
 */
- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Autorelease pool
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
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
        /*
         *  NOTE: lot of weird hackery in here to deal with the messy RSS
         */
        NSString *title = [[item elementForName:@"title"] stringByFlatteningHTML];
        NSString *author = [[[[item elementForName:@"author"] substringFromIndex:1] 
                             stringByReplacingOccurrencesOfString:@" and " withString:@" & "]
                            stringByReplacingOccurrencesOfString:@"the " withString:@""];
        NSString *link = [item elementForName:@"link"];
        NSString *summary = [[[item elementForName:@"description"] stringByRemovingLeadingWhitespace] stringByFlatteningHTML];
        NSDate *pubDate = [pubDateFormatter dateFromString:[item elementForName:@"pubDate"]];
        NSString *guid = [item elementForName:@"guid"];
        NSString *category = [item elementForName:@"category"];
        
        // Allocate a new RSSEntry from feed info & add to unsorted entries
        RSSEntry *entry = [[RSSEntry alloc] initWithTitle:title link:link author:author summary:summary pubDate:pubDate guid:guid category:category];
        JSAssert(entry != nil, @"Error allocating entry");
        [unsortedEntries addObject:entry];
        
        // Parse article text in background
        [self parseArticleTextForEntry:entry];
        // Fetch thumbnail
        NSString *urlString = [[[[item elementsForName:@"thumbnail"] lastObject] attributeForName:@"url"] stringValue];
        entry.thumbnailURL = urlString;
        entry.thumbnail = [[[EGOImageLoader sharedImageLoader] imageForURL:[NSURL URLWithString:urlString] shouldLoadWithObserver:nil] imageCroppedToFitSize:CGSizeMake(70, 70)];
        
        [entry release];
    }
    
    [self sortEntries:unsortedEntries];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [document release];
    [USEnglishLocale release];
    [pubDateFormatter release];
    [unsortedEntries release]; 
    [pool drain];
}

- (void)parseArticleTextForEntry:(RSSEntry *)entry
{
    RSSArticleParser *articleParser = [[RSSArticleParser alloc] initWithRSSEntry:entry];
    articleParser.delegate = _articleViewController;
    
    [_queue addOperationWithBlock:^{
        [articleParser parseArticleText];
        articleParser.delegate = nil;
        [articleParser release];
    }];
}

- (void)sortEntries:(NSMutableArray *)unsortedEntries
{
    for (RSSEntry *entry in unsortedEntries) 
    {
        // Sort by date
        int insertIdx = [_allEntries indexForInsertingObject:[entry retain]
                                            sortedUsingBlock:^(id a, id b) {
                                                RSSEntry *entry1 = (RSSEntry *) a;
                                                RSSEntry *entry2 = (RSSEntry *) b;
                                                return [entry1.pubDate compare:entry2.pubDate];
                                            }];
        // Add to array
        [_allEntries insertObject:entry atIndex:insertIdx];
        [entry release];
        
        // Add to table view
        NSArray *idxPaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:insertIdx inSection:0]];
        [self.tableView insertRowsAtIndexPaths:idxPaths withRowAnimation:UITableViewRowAnimationRight];
    }
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"The Miscellany News";
    
    // Customize title bar
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.502 green:0.0 blue:0.0 alpha:1.];
    [self.navigationController.navigationBar applyNoiseWithOpacity:0.4];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Palatino-Bold" size:20.0];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    label.text = self.title;
    self.navigationItem.titleView = label;
    [label release];
    
    // Customize TableView
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    self.tableView.rowHeight = 80;
    
    // Allocate ivars
    self.allEntries = [NSMutableArray array];
    self.queue = [[NSOperationQueue alloc] init];

    // Show activity indicator
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if (_articleViewController == nil) {
        _articleViewController = [[[ArticleViewController alloc] initWithNibName:@"ArticleViewController" bundle:[NSBundle mainBundle]] retain];
    }
    
    // Begin parsing RSS feed
    [self refreshFeed];
//    [self parseFeed];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc
{
    NSLog(@"dealloc");
    [__fetchedResultsController release];
    [__managedObjectContext release];
    
    [_allEntries release];
    _allEntries = nil;
    
    [_queue release];
    _queue = nil;
    
    [super dealloc];
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
                                       reuseIdentifier:CellIdentifier] autorelease];
    }

    // Configure the cell.
    RSSEntry *entry = [[_allEntries objectAtIndex:indexPath.row] retain];
    
    cell.textLabel.font = [UIFont fontWithName:@"Palatino-Bold" size:16.0];
    cell.textLabel.text = entry.title;
    cell.textLabel.numberOfLines = 2;
    
//    cell.imageView.image = entry.image;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:entry.thumbnail];
    cell.accessoryView = imageView;
    [imageView release];

    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    cell.detailTextLabel.text = entry.summary;
    cell.detailTextLabel.numberOfLines = 2;
    
    [entry release];
    
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
        _articleViewController = [[[ArticleViewController alloc] initWithNibName:@"ArticleViewController" bundle:[NSBundle mainBundle]] retain];
    }

    _articleViewController.entry = [_allEntries objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:[_articleViewController retain] animated:YES];
    
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
	*/
}
@end
