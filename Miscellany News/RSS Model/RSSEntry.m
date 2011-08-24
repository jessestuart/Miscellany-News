//
//  RSSEntry.m
//  Miscellany News
//
//  Created by Jesse Stuart on 8/14/11.
//  Copyright 2011 Vassar College. All rights reserved.
//

#import "RSSEntry.h"
#import "EGOCache.h"
#import "UIImage+ProportionalFill.h"

@implementation RSSEntry

@synthesize guid = _guid;
@synthesize author = _author;
@synthesize title = _title;
@synthesize link = _link;
@synthesize pubDate = _pubDate;
@synthesize summary = _summary;
@synthesize text = _text;
@synthesize thumbnail = _thumbnail;
@synthesize thumbnailURL = _thumbnailURL;

- (id)initWithArticleTitle:(NSString *)articleTitle 
                articleUrl:(NSString *)articleUrl 
               articleDate:(NSDate *)articleDate 
            articleSummary:(NSString *)articleSummary 
               articleText:(NSString *)articleText
{
    if ((self = [super init]))
    {
        _title = [articleTitle copy];
        _link = [articleUrl copy];
        _pubDate = [articleDate copy];
        _summary = [articleSummary copy];
        // even if article text is nil
        _text = [articleText retain];
    }
    return self;
}

- (id)initWithTitle:(NSString *)title 
               link:(NSString *)link 
             author:(NSString *)author 
            summary:(NSString *)summary 
            pubDate:(NSDate *)pubDate 
               guid:(NSString *)guid 
           category:(NSString *)category
{
    if ((self = [super init]))
    {        
        _title = [title copy];
        _link = [link copy];
        _author = [author copy];
        _summary = [summary copy];
        _pubDate = [pubDate copy];
        _guid = [guid copy];
        _category = [category copy];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"dealloc RSSEntry: %@", _title);
    [_title release];
    _title = nil;
    
    [_link release];
    _link = nil;
    
    [_pubDate release];
    _pubDate = nil;
    
    [_text release];
    _text = nil;
    
    [super dealloc];
}

@end
