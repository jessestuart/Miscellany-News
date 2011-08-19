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
#import "UIView+JMNoise.h"
#import "Constants.h"

@implementation ArticleViewController

@synthesize textView = _textView;
@synthesize entry = _entry;


- (void) viewWillAppear:(BOOL)animated
{
    if (_entry.articleText == nil) 
    {
        // If article text has yet to be parsed, show an activity indicator
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    } 
    else if ([_entry.articleText isEqualToString:RSSArticleTextUnavailable])
    {
        _textView.text = @"The text for this article could not be retrieved.";
    }
    else 
    {
        _textView.text = _entry.articleText;  /* (nonatomic, copy) */
    }
}

//- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context 
//{    
//    // Text updated: stop progress indicator & update textView
//    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//        NSLog(@"block");
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
//        _textView.text = [object valueForKeyPath:keyPath];
//    }];
//}

- (void) viewWillDisappear:(BOOL)animated
{
    // Removes progress indicator if found
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    _textView.text = nil;
}

//- (void) viewDidDisappear:(BOOL)animated
//{
//    NSLog(@"before releasing");
//    [_textView.text release];
//    NSLog(@"after releasing");
//    _textView.text = nil;
//}

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
    
    _textView.editable = FALSE;
    _textView.text = nil;

    // Text view is clear on gray textured background
    _textView.backgroundColor = [UIColor clearColor];
    _textView.superview.backgroundColor = [Constants MN_BACKGROUND_COLOR];
    [_textView.superview applyNoiseWithOpacity:0.3];
    _textView.font = [UIFont fontWithName:@"Palatino" size:17.0];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Release any retained subviews of the main 
    // Why does this cause an error right before app termination?
//    self.textView = nil;
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
