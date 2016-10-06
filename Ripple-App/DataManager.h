//
//  DataManager.h
//  Ripple-App
//
//  Created by William O'Connor on 4/19/15.
//  Copyright (c) 2015 Ripple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "REST_API.h"
#import "Strings.h"

@interface DataManager : NSObject

+ (NSDictionary *) getDrops:(NSMutableDictionary*)data;
+ (NSDictionary *) streamSong:(NSString*)song_id;
+ (NSDictionary *) getTrackInfo:(NSString*)song_id;
+ (NSDictionary *) login:(NSMutableDictionary*)data;
+ (NSDictionary *) dropSong:(NSMutableDictionary*)data;
+ (NSDictionary *) redropSong:(NSMutableDictionary*)data;
+ (NSDictionary *) getDropsForUser:(NSString*)data;
+ (NSDictionary *) registerUser:(NSMutableDictionary*)data;
+ (NSDictionary *) creditUser:(NSMutableDictionary*)data;
+ (NSDictionary *) getUserById:(NSString*)data;
+ (NSDictionary *) searchSoundcloud:(NSString*)data;

@end
