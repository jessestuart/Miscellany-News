//
//  RSSEntry.h
//  Miscellany News
//
//  Created by Jesse Stuart on 8/14/11.
//  Copyright 2011 Vassar College. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSSEntry : NSObject
{
    // Set on initialization
    NSString *_title;
    NSString *_link;
    NSString *_author;
    NSString *_summary;
    NSDate *_pubDate;
    NSString *_guid;
    NSString *_category;
    // Set later
    NSString *_text;
    NSString *_thumbnailURL;
    UIImage *_thumbnail;
}

@property (copy) NSString *category;
@property (copy) NSString *guid;
@property (copy) NSString *author;
@property (copy) NSString *title;
@property (copy) NSString *link;
@property (copy) NSDate *pubDate;
@property (copy) NSString *summary;
@property (retain) NSString *text;
@property (retain) UIImage *thumbnail;
@property (copy) NSString *thumbnailURL;

- (id) initWithArticleTitle:(NSString *)articleTitle
                 articleUrl:(NSString *)articleUrl
                articleDate:(NSDate *)articleDate
             articleSummary:(NSString *)articleSummary
                articleText:(NSString *)articleText;

- (id) initWithTitle:(NSString *)title
                link:(NSString *)link
              author:(NSString *)author 
             summary:(NSString *)summary
             pubDate:(NSDate *)pubDate
                guid:(NSString *)guid
            category:(NSString *)category;

              
               
            
            

@end
