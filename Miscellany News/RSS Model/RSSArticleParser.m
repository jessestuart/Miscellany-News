//
//  RSSArticleParser.m
//  Misc
//
//  Created by Jesse Stuart on 8/14/11.
//  Copyright 2011 Vassar College. All rights reserved.
//

#import "RSSArticleParser.h"
#import "TFHpple.h"
#import "NSString+HTML.h"
#import "NSString+JDS.h"
#import "RootViewController.h"

@implementation RSSArticleParser

@synthesize entry = _entry;
@synthesize delegate = _delegate;

- (id)initWithRSSEntry:(RSSEntry *)entry
{
    if((self = [super init]))
    {
        _entry = [entry retain];
    }
    return self;
}

- (NSString *)parseArticleText
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // Load HTML data from article URL & parse with TFHpple
    NSError *error;
    NSString *htmlString = [NSString stringWithContentsOfURL:[NSURL URLWithString:[_entry articleUrl]] 
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
                     stringByFlatteningHTML] 
                    stringByRemovingLeadingWhitespace] 
                   stringByDecodingHTMLEntities];
    
    if (s == nil) {
        _entry.articleText = RSSArticleTextUnavailable;
        return RSSArticleTextUnavailable;
    }
    
    _entry.articleText = s; // copy
    
    [_delegate articleTextParsedForEntry:[_entry retain]];
    
    [pool drain];
    
    return _entry.articleText;
}

- (void)dealloc
{
    NSLog(@"RSSArticleParser dealloc");
    [super dealloc];
    [_entry release];
    _entry = nil;
}
@end