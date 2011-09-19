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
@synthesize category = _category;

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

@end
