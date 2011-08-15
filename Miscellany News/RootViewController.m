//
//  RootViewController.m
//  Miscellany News
//
//  Created by Jesse Stuart on 8/14/11.
//  Copyright 2011 Vassar College. All rights reserved.
//

#import "RootViewController.h"
#import "RSSEntry.h"
#import "NSArray+Extras.h" 
#import "MBProgressHUD.h"

@interface RootViewController () 
    @property (retain) NSMutableArray *unsortedEntries;
@end

@implementation RootViewController

@synthesize unsortedEntries;
@synthesize allEntries = _allEntries;
@synthesize queue = _queue;

@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;

#pragma mark Feed parsing

- (void)parseFeed
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        // Create feed parser and pass the URL of the feed
        NSURL *feedURL = [NSURL URLWithString:@"feed://www.miscellanynews.com/se/1.38617"];
        MWFeedParser *feedParser = [[MWFeedParser alloc] initWithFeedURL:feedURL];
        // Delegate must conform to MWFeedParserDelegate
        feedParser.delegate = self;
        
        // Parse the feeds info (title, link) and all feed items
        feedParser.feedParseType = ParseTypeItemsOnly;
        // Connection type
        feedParser.connectionType = ConnectionTypeSynchronously;
        // Begin parsing
        [feedParser parse];
    }];
}

#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Miscellany News";    
    self.allEntries = [NSMutableArray array];
    self.unsortedEntries = [NSMutableArray array];
    self.queue = [[[NSOperationQueue alloc] init] autorelease];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self parseFeed];

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

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

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
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }

    // Configure the cell.
    RSSEntry *entry = [_allEntries objectAtIndex:indexPath.row];
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *articleDateString = [dateFormatter stringFromDate:entry.articleDate];
    
    cell.textLabel.text = entry.articleTitle;
    cell.detailTextLabel.text = articleDateString;
    
    return cell;
//    [self configureCell:cell atIndexPath:indexPath];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the managed object for the given index path
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        // Save the context.
        NSError *error = nil;
        if (![context save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
	*/
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
    [__fetchedResultsController release];
    [__managedObjectContext release];
    
    [_allEntries release];
    _allEntries = nil;
    
    [_queue release];
    _queue = nil;
    
    [super dealloc];
}

#pragma mark MWFeedParser Delegate Methods

-(void)feedParserDidStart:(MWFeedParser *)parser
{
    NSLog(@"Parsing begun.");
}

-(void)feedParser:(MWFeedParser *)parser 
 didParseFeedItem:(MWFeedItem *)item
{
    NSLog(@"Parsing item with title %@", item.title);
    // Create RSSEntry from parsed item and add to array
    RSSEntry *entry = [[[RSSEntry alloc] initWithArticleTitle:item.title 
                                 articleUrl:item.link 
                                articleDate:item.date 
                                articleText:nil] autorelease];
    [unsortedEntries addObject:entry];
}

-(void)feedParserDidFinish:(MWFeedParser *)parser
{
    NSLog(@"Parsing completed.");
    for (RSSEntry *entry in unsortedEntries) 
    {
        // Sort by date
        int insertIdx = [_allEntries indexForInsertingObject:entry sortedUsingBlock:^(id a, id b) {
            RSSEntry *entry1 = (RSSEntry *) a;
            RSSEntry *entry2 = (RSSEntry *) b;
            return [entry1.articleDate compare:entry2.articleDate];
        }];
        // Add to array
        [_allEntries insertObject:entry atIndex:insertIdx];
        // Add to table view
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:insertIdx inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
@end
