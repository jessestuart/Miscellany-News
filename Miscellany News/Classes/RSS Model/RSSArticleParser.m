//
//  RSSArticleParser.m
//  Misc
//
//  Created by Jesse Stuart on 8/14/11.
//  Copyright 2011 Vassar College. All rights reserved.
//

#import "RSSArticleParser.h"
#import "NSString+HTML.h"
#import "NSString+JDS.h"
#import "RootViewController.h"

NSString * const RSSArticleTextUnavailable = @"rss_article_text_unavailable";

@implementation RSSArticleParser

@synthesize entry = _entry;
@synthesize delegate = _delegate;

- (id)initWithRSSEntry:(RSSEntry *)entry
{
    if((self = [super init]))
    {
        _entry = entry;
    }
    return self;
}

- (void)parseArticleText
{
    @autoreleasepool
    {   
        // Load HTML data from article URL & parse
        NSError *error;
        NSString *htmlString = [NSString stringWithContentsOfURL:[NSURL URLWithString:[_entry link]] 
                                                        encoding:NSUTF8StringEncoding 
                                                           error:&error];
        
        // Article text starts here...
        NSUInteger begin = [htmlString rangeOfString:@"<div class=\"text\">"].location;
        // ...and ends here
        NSUInteger end = [htmlString rangeOfString:@"<div id=" 
                                           options:NSCaseInsensitiveSearch 
                                             range:NSMakeRange(begin, [htmlString length]-begin)].location;
        
        // Cut out article text substring, flatten HTML tags, etc
        NSString *s = [[[[htmlString substringWithRange:NSMakeRange(begin, end-begin)] 
                         // remove html and tabs
                         stringByStrippingMatchingRegex:@"<[^>]+>|\t"] 
                        stringByRemovingLeadingWhitespace]
                       stringByDecodingHTMLEntities];
        
        if (s == nil) 
        {
            _entry.text = RSSArticleTextUnavailable;
        }
        
        [_entry setText:s]; // retain 
        
        [_delegate articleTextParsedForEntry:_entry];
        
    }
}

@end