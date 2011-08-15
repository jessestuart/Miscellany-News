//
//  RSSArticleParser.m
//  Misc
//
//  Created by Jesse Stuart on 8/14/11.
//  Copyright 2011 Vassar College. All rights reserved.
//

#import "RSSArticleParser.h"
#import "TFHpple.h"

@implementation RSSArticleParser

@synthesize entry = _entry;

- (id)initWithRSSEntry:(RSSEntry *)entry
{
    if((self = [super init]))
    {
        _entry = [entry retain];
    }
    return self;
}

- (void)parseArticleText
{
    NSLog(@"Parsing article entitled \"%@\"", _entry.articleTitle);
    NSMutableString *text = [[NSMutableString alloc] init];
    
    // Load HTML data from article URL & parse with TFHpple
    NSError *error;
    NSString *htmlString = [NSString stringWithContentsOfURL:[NSURL URLWithString:[_entry articleUrl]] 
                                                   encoding:NSUTF8StringEncoding 
                                                      error:&error];
    NSData *htmlData = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    // Creates array of all the paragraphs in the article
    NSArray *paragraphs  = [xpathParser search:@"//div[@class='text']//p"];
    // Recreate nsstring by appending paragraphs together with linebreaks
    for (id paragraph in paragraphs) 
    {
        NSString *content = [(TFHppleElement *) paragraph content];
        [text appendString:[NSString stringWithFormat:@"%@\n\n", content]];
    }
    
    [self.entry setArticleText:[NSString stringWithString:text]];
    [text release];
    [htmlData release];
    [xpathParser release];
//    [paragraphs release];
}

- (void)dealloc
{
    [super dealloc];
    [_entry release];
    _entry = nil;
}
@end