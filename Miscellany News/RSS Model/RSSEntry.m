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

@synthesize articleTitle = _articleTitle;
@synthesize articleUrl = _articleUrl;
@synthesize articleDate = _articleDate;
@synthesize articleSummary = _articleSummary;
@synthesize articleText = _articleText;
@synthesize image = _image;

//- (UIImage *)image
//{
//    return self.image;
//}
//
//- (void)setImage:(UIImage *)image
//{
//    NSLog(@"cropping image");
//    self.image = [image imageCroppedToFitSize:CGSizeMake(60, 60)];
//    NSLog(@"done cropping image");
//}



- (id)initWithArticleTitle:(NSString *)articleTitle 
                articleUrl:(NSString *)articleUrl 
               articleDate:(NSDate *)articleDate 
            articleSummary:(NSString *)articleSummary 
               articleText:(NSString *)articleText
{
    if ((self = [super init]))
    {
        _articleTitle = [articleTitle copy];
        _articleUrl = [articleUrl copy];
        _articleDate = [articleDate copy];
        _articleSummary = [articleSummary copy];
        // even if article text is nil
        _articleText = [articleText retain];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"dealloc RSSEntry: %@", _articleTitle);
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
