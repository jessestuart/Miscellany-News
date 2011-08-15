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
#import "RSSArticleParser.h"

@implementation ArticleViewController

@synthesize textView = _textView;
@synthesize entry = _entry;


- (void) viewWillAppear:(BOOL)animated
{
    NSString *articleText = [_entry.articleText retain];
    _textView.text = articleText;
    
    if (articleText == nil) 
    {
        // If article text has yet to be parsed, show an activity indicator
        // and register an observer so that textView can be updated when
        // parsing is complete
        [_entry addObserver:self forKeyPath:@"articleText" options:0 context:nil];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
}

- (void) observeValueForKeyPath:(NSString *)keyPath 
                       ofObject:(id)object
                         change:(NSDictionary *)change 
                        context:(void *)context 
{
    [_entry removeObserver:self forKeyPath:keyPath];
    
    // Text updated: stop progress indicator & update textView
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        _textView.text = [object valueForKeyPath:keyPath];
    }];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [_entry release];
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
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _textView.editable = FALSE;
    _textView.directionalLockEnabled = TRUE;
    _textView.text = nil;
//    _textView.backgroundColor = [UIColor colorWithRed:0.93 green:0.92 blue:0.91 alpha:1.0];
//    _textView.textColor = [UIColor colorWithRed:0.1725 green:0.1764 blue:0.1960 alpha:1.0];
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

- (void)dealloc
{
    [super dealloc];
    [_entry release];
    _entry = nil;
    [_textView release];
    _textView = nil;
}

@end
