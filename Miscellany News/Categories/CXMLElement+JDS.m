//
//  CXMLElement+(JDS).m
//  Miscellany News
//
//  Created by Jesse Stuart on 8/23/11.
//  Copyright 2011 Vassar College. All rights reserved.
//

#import "CXMLElement+(JDS).h"

@implementation CXMLElement (JDS)

- (NSString *)elementForName:(NSString *)name
{
    return [[[self elementsForName:name] lastObject] stringValue];
}

@end
