//
//  Rankings.m
//  Ripple-App
//
//  Created by William O'Connor on 11/28/16.
//  Copyright © 2016 Ripple, LLC. All rights reserved.
//

#import "Rankings.h"

@implementation Rankings

+(NSDictionary*)getRankingToColorDictionary:(int)rank
{
    NSString* key = [NSString stringWithFormat:@"%i", rank];
    NSDictionary* rankings = [[NSDictionary alloc] initWithObjectsAndKeys:@[@"pink", @"0",
                                                                            @"light-blue", @"1",
                                                                            @"navy", @"2"], nil];
    return rankings[key];
}

@end
