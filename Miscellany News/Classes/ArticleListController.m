//
//  ArticleListController.m
//  Miscellany News
//
//  Created by Jesse Stuart on 9/20/11.
//  Copyright (c) 2011 Vassar College. All rights reserved.
//

#import "ArticleListController.h"

#import "RSSEntry.h"
#import "ArticleViewController.h"
#import "RootViewController.h"
#import "AppDelegate.h"

@implementation ArticleListController

@synthesize tableView = _tableView;
@synthesize refreshHeaderView = _refreshHeaderView;
@synthesize articleViewController = _articleViewController;
@synthesize allEntries = _allEntries;

- (id)initWithCategoryFilter:(int)category
{
    if ((self = [super init])) 
    {
        _category = category;
        
        
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

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    
    _tableView = [[UITableView alloc] initWithFrame:[[self view] bounds] style:UITableViewStylePlain];
    [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [self.view addSubview:_tableView];

    /*
     * Load EGORefreshTableHeaderView
     */
    if (_refreshHeaderView == nil) 
    {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height) arrowImageName:@"blackArrow.png" textColor:[UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0]];
        view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
		view.delegate = self;
		[[self tableView] addSubview:view];
		_refreshHeaderView = view;
	}
    
    // Update the last update date
    [_refreshHeaderView refreshLastUpdatedDate];
}

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
    
    return cell;
}

// Don't allow any editing
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
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
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource
{	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;	
}

- (void)doneLoadingTableViewData
{	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];	
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];	
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{	
	[self reloadTableViewDataSource];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{	
	return _reloading; // should return if data source model is reloading	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{	
	return [NSDate date]; // should return date data source was last changed	
}

@end
