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
    IBOutlet UITextView *_textView;
    RSSEntry *_entry;
}

@property (retain) UITextView *textView;
@property (retain) RSSEntry *entry;

@end
