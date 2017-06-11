//
//  Rankings.m
//  Ripple-App
//
//  Created by William O'Connor on 11/28/16.
//  Copyright © 2016 Ripple, LLC. All rights reserved.
//

#import "Rankings.h"
#import "Colors.h"

@implementation Rankings

+(NSString*)getRankingToColorString:(int)rank
{
    NSString* key = [NSString stringWithFormat:@"%i", rank];
    NSDictionary* rankings = [[NSDictionary alloc] initWithObjectsAndKeys: @"pink", @"0",
                                                                           @"light-blue", @"1",
                                                                           @"navy", @"2",
                                                                           nil];
    return rankings[key];
}

+(UIColor*)getRankingToUIColor:(int)rank
{
    NSString* key = [NSString stringWithFormat:@"%i", rank];
    NSDictionary* rankings = [[NSDictionary alloc] initWithObjectsAndKeys: cPrimaryPink, @"0",
                                                                           cPrimaryLightBlue, @"1",
                                                                           cPrimaryNavy, @"2",
                                                                           nil];
    return rankings[key];
}

+(NSString*)getPointsToRanking:(float)points
{
    // keep formula consistent with node project /server/controllers/rankings.js
    NSString* key = [NSString stringWithFormat:@"%f", floorf(points/10)];
    NSDictionary* rankings = [[NSDictionary alloc] initWithObjectsAndKeys: @"0", @"0",
                                                                           @"1", @"1",
                                                                           @"2", @"2",
                                                                           nil];
    return rankings[key];
}

+(float)getPointsToProgress:(float)points
{
    // keep formula consistent with node project /server/controllers/rankings.js
    float progress = ((float)((int)points % 10)) / 10;
    
    return progress;
}

@end
