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

@interface ArticleViewController ()
    @property BOOL _observing;
@end

@implementation ArticleViewController

@synthesize _observing;
@synthesize textView = _textView;
@synthesize entry = _entry;


- (void) viewWillAppear:(BOOL)animated
{
    NSLog(@"view will appear");
    
    NSString *articleText = [_entry.articleText retain];
    
    if (articleText == nil) 
    {
        NSLog(@"article text is nil!");
        // If article text has yet to be parsed, show an activity indicator
        // and register an observer so that textView can be updated when
        // parsing is complete
//        [_entry addObserver:self forKeyPath:@"articleText" options:0 context:nil];
//        _observing = TRUE;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    } 
    else if ([articleText isEqualToString:RSSArticleTextUnavailable])
    {
        _textView.text = @"Sorry, the text for this article could not be retrieved.";
    }
    else {
        _textView.text = articleText;  // (nonatomic, copy)  
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
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    //    if (_observing) {
    //        [_entry removeObserver:self forKeyPath:@"articleText"];
    //        [MBProgressHUD hideHUDForView:self.view animated:YES];
    //        _observing = FALSE;
    //    }
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
    
    _observing = FALSE;
    _textView.editable = FALSE;
    _textView.text = nil;

    // Text view is clear on gray textured background
    _textView.backgroundColor = [UIColor clearColor];
    _textView.superview.backgroundColor = [UIColor colorWithRed:0.941 green:0.941 blue:0.941 alpha:1.];
    [_textView.superview applyNoise];
    _textView.font = [UIFont fontWithName:@"Palatino" size:17.0];
//    _textView.textColor = [UIColor colorWithRed:0.1725 green:0.1764 blue:0.1960 alpha:1.0];
}

- (void)viewDidUnload
{
    NSLog(@"view did unload");
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
//    [_textView release];
//    _textView = nil;
}

@end
