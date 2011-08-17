//
//  RSSEntry.h
//  Miscellany News
//
//  Created by Jesse Stuart on 8/14/11.
//  Copyright 2011 Vassar College. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const RSSArticleTextUnavailable;

@interface RSSEntry : NSObject
{
    NSString *_articleTitle;
    NSString *_articleUrl;
    NSDate *_articleDate;
    NSString *_articleText;
}

@property (copy) NSString *articleTitle;
@property (copy) NSString *articleUrl;
@property (copy) NSDate *articleDate;
@property (copy) NSString *articleText;

- (id) initWithArticleTitle:(NSString *)ArticleTitle
                 articleUrl:(NSString *)articleUrl
                articleDate:(NSDate *)articleDate
                articleText:(NSString *)articleText;

@end
