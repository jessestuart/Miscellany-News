//
//  RSSEntry.m
//  Miscellany News
//
//  Created by Jesse Stuart on 8/14/11.
//  Copyright 2011 Vassar College. All rights reserved.
//

#import "RSSEntry.h"

@implementation RSSEntry

@synthesize articleTitle = _articleTitle;
@synthesize articleUrl = _articleUrl;
@synthesize articleDate = _articleDate;
@synthesize articleText = _articleText;

- (id)initWithArticleTitle:(NSString *)articleTitle 
                articleUrl:(NSString *)articleUrl 
               articleDate:(NSDate *)articleDate 
               articleText:(NSString *)articleText
{
    if ((self = [super init]))
    {
        _articleTitle = [articleTitle copy];
        _articleUrl = [articleUrl copy];
        _articleDate = [articleDate copy];
        // even if article text is nil
        _articleText = [articleText copy];
    }
    return self;
}

- (void)dealloc
{
    
    [_articleTitle release];
    _articleTitle = nil;
    
    [_articleUrl release];
    _articleUrl = nil;
    
    [_articleDate release];
    _articleDate = nil;
    
    [_articleText release];
    _articleText = nil;
    
    [super dealloc];
}

@end
