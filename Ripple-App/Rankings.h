//
//  Rankings.h
//  Ripple-App
//
//  Created by William O'Connor on 11/28/16.
//  Copyright © 2016 Ripple, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Rankings : NSObject

+(NSString*)getRankingToColorString:(int)rank;
+(UIColor*)getRankingToUIColor:(int)rank;
+(NSString*)getPointsToRanking:(float)points;
+(float)getPointsToProgress:(float)points;

@end
