//
//  ArticleViewController.m
//  Miscellany News
//
//  Created by Jesse Stuart on 8/15/11.
//  Copyright 2011 Vassar College. All rights reserved.
//

#import "ArticleViewController.h"
#import "RSSEntry.h"
#import "MBProgressHUD.h"
#import "UIView+JMNoise.h"
#import "EGOImageLoader.h"
#import "UIImage+ProportionalFill.h"
#import "SHK.h"

@implementation ArticleViewController

@synthesize entry = _entry,
            scrollView = _scrollView,
            textView = _textView,
            titleLabel = _titleLabel,
            authorAndDateLabel = _authorAndDateLabel,
            categoryLabel = _categoryLabel;

#pragma mark -
#pragma mark ShareKit

- (void)shareArticle
{
    // Create the item to share (in this example, a url)
	NSURL *url = [NSURL URLWithString:_entry.link];
	SHKItem *item = [SHKItem URL:url title:@"Share article"];
    
	// Get the ShareKit action sheet
	SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
    
	// Display the action sheet
	[actionSheet showFromToolbar:self.navigationController.toolbar];
}

#pragma mark -
#pragma mark RSSArticleParser delegate methods

- (void)articleTextParsedForEntry:(RSSEntry *)entry
{
    // Article text has just been set for currently selected article,
    // so set textView's text and hide the activity indicator.
    if (entry == self.entry) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            _textView.text = entry.text;;
            CGRect frame = _textView.frame;
            frame.size.height = _textView.contentSize.height;
            _textView.frame = frame;
            _scrollView.contentSize = CGSizeMake(frame.size.width, frame.size.height + 50);
            
            [_scrollView scrollRectToVisible:CGRectMake(0, 0, 320, 320) animated:NO];
            
            [MBProgressHUD hideHUDForView:self.view animated:YES]; 
        }];
    }
}

#pragma mark -
#pragma mark View loading

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



#pragma mark -
#pragma mark - View lifecycle

- (void) viewWillAppear:(BOOL)animated
{
    if (_entry.text == nil) 
    {
        // If article text has yet to be parsed, show an activity indicator
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    } 
    else if ([_entry.text isEqualToString:RSSArticleTextUnavailable])
    {
        _textView.text = @"The text for this article could not be retrieved.";
    }
    else
    {
        // If article text is available, set text view's text and adjust scroll view to fit
        self.textView.text = _entry.text;
        CGRect frame = _textView.frame;
        frame.size.height = _textView.contentSize.height;
        _textView.frame = frame;
        _scrollView.contentSize = CGSizeMake(frame.size.width, frame.size.height + 50);
        
        [_scrollView scrollRectToVisible:CGRectMake(0, 0, 320, 320) animated:NO];
    }
    
    // Confirm that entry isn't nil
    JSAssert(_entry != nil, @"Error: entry is nil before article view will appear");
    
    self.titleLabel.text = _entry.title;
    self.authorAndDateLabel.text = [NSString stringWithFormat:@"%@- %@", _entry.author, [_df stringFromDate:_entry.pubDate]];
    self.categoryLabel.text = _entry.category;
}

-(void) viewDidDisappear:(BOOL)animated
{
    // Hide progress indicator, if it was shown
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    // Clear all text fields
    _textView.text = nil;
    _titleLabel.text = nil;
    _authorAndDateLabel.text = nil;
    _categoryLabel.text = nil;
    
    // Reset scroll view content size
    _scrollView.contentSize = CGSizeMake(320.0, 10.0);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set scroll view background to that cool paper pattern image
    _scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    
    // Scroll view can scroll, but not text view. This way, everything will scroll together.
    _scrollView.scrollEnabled = YES;
    _textView.scrollEnabled = NO;
    
    // Configure text view
    _textView.backgroundColor = [UIColor clearColor];
    _textView.editable = FALSE;
    _textView.font = [UIFont fontWithName:@"Helvetica Neue" size:15.0];
    _textView.textColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0];
    
    // Clear all text fields (just in case)
    _textView.text = nil;
    _titleLabel.text = nil;
    _authorAndDateLabel.text = nil;
    _categoryLabel.text = nil;
    
    // Add right bar button item for sharing articles
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareArticle)];
    self.navigationItem.rightBarButtonItem = shareButton;
    
    // Initialize date formatter for later
    _df = [[NSDateFormatter alloc] init];
    _df.dateStyle = NSDateFormatterMediumStyle;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload
{
    [super viewDidUnload];
    // TODO
    
    // Release any retained subviews of the main 
    // e.g. self.myOutlet = nil;
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"did receive memory warning");
    
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

@end
