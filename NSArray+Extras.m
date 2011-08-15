//
//  NSArray+Extras.m
//  Misc
//
//  Created by Jesse Stuart on 8/13/11.
//  Copyright 2011 Vassar College. All rights reserved.
//

#import "NSArray+Extras.h"

@implementation NSArray (Extras)

- (NSUInteger)indexForInsertingObject:(id)anObject sortedUsingBlock:(compareBlock)compare
{
    NSUInteger index = 0;
    NSUInteger topIndex = [self count];
    while (index < topIndex) 
    {
        NSUInteger midIndex = (index + topIndex) / 2;
        id testObject = [self objectAtIndex:midIndex];
        
        if (compare(anObject, testObject) < 0) 
        {
            index = midIndex + 1;
        }
        else
        {
            topIndex = midIndex;
        }
    }
    
    return index;
}

@end