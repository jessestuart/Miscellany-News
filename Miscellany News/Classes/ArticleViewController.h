//
//  ArticleViewController.h
//  Miscellany News
//
//  Created by Jesse Stuart on 8/15/11.
//  Copyright 2011 Vassar College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSSArticleParser.h"

@class RSSEntry;

@interface ArticleViewController : UIViewController <RSSArticleParserDelegate>
{
    NSDateFormatter *_df;
}

@property (retain) RSSEntry *entry;

@property (retain) IBOutlet UIScrollView *scrollView;
@property (retain) IBOutlet UITextView *textView;
@property (retain) IBOutlet UILabel *titleLabel;
@property (retain) IBOutlet UILabel *authorAndDateLabel;
@property (retain) IBOutlet UILabel *categoryLabel;

@end
