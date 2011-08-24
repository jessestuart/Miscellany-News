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
    RSSEntry *_entry;
    IBOutlet UIScrollView *_scrollView;
    IBOutlet UITextView *_textView;
    IBOutlet UIImageView *_thumbnailView;
    IBOutlet UILabel *_titleLabel;
    IBOutlet UILabel *_authorLabel;
}

@property (retain) RSSEntry *entry;
@property (retain) UIScrollView *scrollView;
@property (retain) UITextView *textView;
@property (retain) UIImageView *thumbnailView;
@property (retain) UILabel *titleLabel;
@property (retain) UILabel *authorLabel;

@end
