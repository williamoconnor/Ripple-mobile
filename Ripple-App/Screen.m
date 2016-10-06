//
//  Screen.m
//  Buyers Marque
//
//  Created by William O'Connor on 1/18/16.
//  Copyright © 2016 HundredDollaBill Development. All rights reserved.
//

#import "Screen.h"


@implementation Screen

+(NSDictionary*) screenDimensions {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    NSNumber *height = [[NSNumber alloc] initWithDouble:screenHeight];
    NSNumber *width = [[NSNumber alloc] initWithDouble:screenWidth];
    
    NSDictionary* screenInfo = [[NSDictionary alloc] initWithObjects:@[width, height] forKeys:@[@"width", @"height"]];
    
    return screenInfo;
}

@end
