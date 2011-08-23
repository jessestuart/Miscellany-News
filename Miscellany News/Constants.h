//
//  Constants.h
//  Miscellany News
//
//  Created by Jesse Stuart on 8/19/11.
//  Copyright 2011 Vassar College. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * I know, I know, there's better ways to do this than class
 * methods. If somebody could explain to me how to get extern
 * constants working with something like UIColors, I'd love
 * to hear about it.
 */

@interface Constants : NSObject

+ (UIColor *)MN_BACKGROUND_COLOR;

@end
