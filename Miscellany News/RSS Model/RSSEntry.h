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
    NSString *_articleTitle; // title
    NSString *_articleUrl; // link
    NSString *_author;
    NSString *_articleSummary; // summary
    NSDate *_articleDate; // pubDate
    NSString *_guid;
    NSString *_category;

    NSString *_articleText; //text
    UIImage *_image; // thumbnail
}

@property (copy) NSString *guid;
@property (copy) NSString *author;
@property (copy) NSString *articleTitle;
@property (copy) NSString *articleUrl;
@property (copy) NSDate *articleDate;
@property (copy) NSString *articleSummary;
@property (retain) NSString *articleText;
@property (retain) UIImage *image;

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
