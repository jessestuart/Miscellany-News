//
//  RSSFeedLoader.m
//  Miscellany News
//
//  Created by Jesse Stuart on 9/19/11.
//  Copyright (c) 2011 Vassar College. All rights reserved.
//

#import "RSSFeedLoader.h"
#import "RSSEntry.h"
#import "ASIHTTPRequest.h"
#import "TouchXML.h"
#import "CXMLElement+JDS.h"
#import "EGOImageLoader.h"
#import "UIImage+ProportionalFill.h"
#import "NSString+JDS.h"
#import "NSString+HTML.h"

@interface RSSFeedLoader ()
- (MNEntryCategory)categoryIDForCategory:(NSString *)category;
@end

@implementation RSSFeedLoader

@synthesize delegate = _delegate;
@synthesize queue = _queue;
@synthesize feedURL = _feedURL;

- (id)initWithFeedURL:(NSURL *)feedURL
{
    if ((self = [super init])) 
    {
        _feedURL = feedURL;
        _queue = [[NSOperationQueue alloc] init];
    }
    return self;
}

/**
 *  Initialize an HTTP request for the RSS feed data
 */
- (void)loadFeed
{
    // Pull feed URL from info plist, initialize ASIHTTP request, and add to queue
    NSURL *miscFeedURL = [NSURL URLWithString:[[[NSBundle mainBundle] infoDictionary] valueForKey:jFeedURL]];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:miscFeedURL];
    request.delegate = self;
    [_queue addOperation:request];
}

#pragma mark -
#pragma mark ASIHTTPRequest callbacks
/**
 *  ASIHTTPRequestDelegate callback. Display a "Failed to retrieve feed" alert view.
 */
- (void)requestFailed:(ASIHTTPRequest *)request
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network error" 
                                                    message:@"Failed to retrieve feed." 
                                                   delegate:nil 
                                          cancelButtonTitle:@"Close" 
                                          otherButtonTitles:nil];
    [alert show];
}

/**
 *  ASIHTTPRequestDelegate callback. 
 */
- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Working array for unsorted RSS entries
    NSMutableArray *unsortedEntries = [[NSMutableArray alloc] init];
    
    // Initialize XML document with feed data
    NSError *error = nil;
    CXMLDocument *document = [[CXMLDocument alloc] initWithData:[request responseData] options:0 error:&error];
    JSAssert(error == nil, @"Error creating document from feed");
    
    // We can use the channel element to get to all of the RSS items
    CXMLElement *channel = [[[document rootElement] elementsForName:@"channel"] lastObject];
    
    // Initialize date formatter. We'll use this to convert the pubDate into an NSDate object
    NSDateFormatter *pubDateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *USEnglishLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [pubDateFormatter setLocale:USEnglishLocale];
    [pubDateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
    
    // Recurse over all the RSS items in the feed
    for (CXMLElement *item in [channel elementsForName:@"item"])
    {
        @autoreleasepool 
        {
            /* NOTE: lot of weird hackery in here to deal with the messy RSS */
            NSString *title = [[item elementForName:@"title"] stringByFlatteningHTML];
            NSString *author = [[[[item elementForName:@"author"] substringFromIndex:1] 
                                 stringByReplacingOccurrencesOfString:@" and " withString:@" & "]
                                stringByReplacingOccurrencesOfString:@"the " withString:@""];
            NSString *link = [item elementForName:@"link"];
            NSString *summary = [[[[item elementForName:@"description"] stringByRemovingLeadingWhitespace] stringByFlatteningHTML] stringByDecodingHTMLEntities];
            NSDate *pubDate = [pubDateFormatter dateFromString:[item elementForName:@"pubDate"]];
            NSString *guid = [item elementForName:@"guid"];
            NSString *category = [item elementForName:@"category"];
            int categoryID = [self categoryIDForCategory:category];
            
            
//            NSLog(@"category: %@", category);
            
            // Allocate a new RSSEntry from feed info & add to unsorted entries
            RSSEntry *entry = [[RSSEntry alloc] initWithTitle:title link:link author:author summary:summary pubDate:pubDate guid:guid category:category categoryID:categoryID];
            JSAssert(entry != nil, @"Error allocating entry");
            [unsortedEntries addObject:entry];
            
            // Fetch thumbnail
            entry.thumbnailURL = [[[[item elementsForName:@"thumbnail"] lastObject] attributeForName:@"url"] stringValue];
            entry.thumbnail = [[[EGOImageLoader sharedImageLoader] imageForURL:[NSURL URLWithString:entry.thumbnailURL] shouldLoadWithObserver:nil] imageCroppedToFitSize:CGSizeMake(70, 70)];
            
            // Delegate will take care of parsing article text
            [_delegate feedLoaderDidLoadEntry:entry];
        }
    }
    
    [_delegate feedLoaderFinishedLoadingEntries:unsortedEntries];
}

- (MNEntryCategory)categoryIDForCategory:(NSString *)category
{
    // News category
    if ([category isEqualToString:@"News"])
    {
        return MNNewsCategory;
    }
    // Features category (plus unfiled)
    else if ([category isEqualToString:@"Features"] || 
             [category isEqualToString:@"The Miscellany News"] ||
             [category isEqualToString:@"Meet Vassar College"])
    {
        return MNFeaturesCategory;
    }
    // Opinions category
    else if ([category isEqualToString:@"Opinions"])
    {
        return MNOpinionsCategory;
    }
    // Arts category
    else if ([category isEqualToString:@"Arts"])
    {
        return MNArtsCategory;
    }
    // Sports category
    else if ([category isEqualToString:@"Sports"])
    {
        return MNSportsCategory;
    }
    // Unrecognized
    else
    {
        NSLog(@"Unrecognized category: %@", category);
        return -1;
    }
}

@end