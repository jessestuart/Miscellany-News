//
//  RSSEntry.h
//  Miscellany News
//
//  Created by Jesse Stuart on 8/14/11.
//  Copyright 2011 Vassar College. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSSEntry : NSObject

@property (readonly, copy) NSString *category;
@property (readonly, copy) NSString *guid;
@property (readonly, copy) NSString *author;
@property (readonly, copy) NSString *title;
@property (readonly, copy) NSString *link;
@property (readonly, copy) NSDate *pubDate;
@property (readonly, copy) NSString *summary;
@property (retain) NSString *text;
@property (retain) UIImage *thumbnail;
@property (copy) NSString *thumbnailURL;

- (id) initWithTitle:(NSString *)title
                link:(NSString *)link
              author:(NSString *)author 
             summary:(NSString *)summary
             pubDate:(NSDate *)pubDate
                guid:(NSString *)guid
            category:(NSString *)category;

@end
