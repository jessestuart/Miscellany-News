//
//  CXMLElement+(JDS).h
//  Miscellany News
//
//  Created by Jesse Stuart on 8/23/11.
//  Copyright 2011 Vassar College. All rights reserved.
//

#import "CXMLElement.h"

@interface CXMLElement (JDS)

/**
 * Shorthand for [[[element elementsForName@"name"] lastObject] stringValue]
 */
- (NSString *)elementForName:(NSString *)name;

@end
