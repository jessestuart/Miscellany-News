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
#import "Constants.h"
#import "EGOImageLoader.h"
#import "UIImage+ProportionalFill.h"

@implementation ArticleViewController

@synthesize entry = _entry;
@synthesize scrollView = _scrollView;
@synthesize textView = _textView;
@synthesize titleLabel = _titleLabel;
@synthesize authorAndDateLabel = _authorAndDateLabel;
@synthesize categoryLabel = _categoryLabel;

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
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateStyle = NSDateFormatterMediumStyle;
        
        self.textView.text = _entry.text;
        self.titleLabel.text = _entry.title;
        self.authorAndDateLabel.text = [NSString stringWithFormat:@"%@– %@", _entry.author, [df stringFromDate:_entry.pubDate]];
        self.categoryLabel.text = _entry.category;
        
        [_textView setScrollEnabled:NO];
        [_scrollView setScrollEnabled:YES];       
        CGRect frame = _textView.frame;
        frame.size.height = _textView.contentSize.height;
        _textView.frame = frame;
        _scrollView.contentSize = CGSizeMake(frame.size.width, frame.size.height + 50);
        
        [_scrollView scrollRectToVisible:CGRectMake(0, 0, 320, 320) animated:NO];
    }
}

-(void) viewDidDisappear:(BOOL)animated
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    _textView.text = nil;
    _scrollView.contentSize = CGSizeMake(320.0, 10.0);
}

- (void)articleTextParsedForEntry:(RSSEntry *)entry
{
    // Article text has just been set for currently selected article,
    // so set textView's text and hide the activity indicator.
    if (entry == self.entry) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [MBProgressHUD hideHUDForView:self.view animated:YES]; 
            _textView.text = entry.text;
        }];
    }
}

#pragma mark View loading
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"did receive memory warning");
    
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    
    _textView.backgroundColor = [UIColor clearColor];
    _textView.editable = FALSE;
    _textView.font = [UIFont fontWithName:@"Helvetica Neue" size:15.0];
    _textView.textColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0];
    
    _textView.editable = FALSE;
    _textView.text = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Release any retained subviews of the main 
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [super dealloc];
    [_entry release];
    _entry = nil;
}

@end
