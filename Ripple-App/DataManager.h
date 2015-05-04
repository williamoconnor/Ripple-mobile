//
//  DataManager.h
//  Ripple-App
//
//  Created by William O'Connor on 4/19/15.
//  Copyright (c) 2015 Gooey Dee Bee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "REST_API.h"
#import "Strings.h"

@interface DataManager : NSObject

+ (NSDictionary *) getSongList:(NSMutableDictionary*)data;
+ (NSDictionary *) streamSong:(NSString*)song_id;
+ (NSDictionary *) getTrackInfo:(NSString*)song_id;
+ (NSDictionary *) signIn:(NSMutableDictionary*)data;
+ (NSDictionary *) dropSong:(NSMutableDictionary*)data;
+ (NSDictionary *) getUserInfo:(NSString*)email;

@end
