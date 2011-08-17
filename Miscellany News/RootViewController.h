//
//  RootViewController.h
//  Miscellany News
//
//  Created by Jesse Stuart on 8/14/11.
//  Copyright 2011 Vassar College. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>
#import "MWFeedParser.h"
#import "ArticleViewController.h"
#import "RSSArticleParser.h"

@interface RootViewController : UITableViewController <MWFeedParserDelegate, RSSArticleParserDelegate>
{
    ArticleViewController *_articleViewController;
    NSMutableArray *_allEntries;
    NSOperationQueue *_queue;
}

@property (retain) ArticleViewController *articleViewController;

@property (retain) NSMutableArray *allEntries;
@property (retain) NSOperationQueue *queue;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
