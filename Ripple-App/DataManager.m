//
//  DataManager.m
//  Ripple-App
//
//  Created by William O'Connor on 4/19/15.
//  Copyright (c) 2015 Gooey Dee Bee. All rights reserved.
//

#import "DataManager.h"

@implementation DataManager

+ (NSDictionary *)getSongList:(NSMutableDictionary*)data
{
    NSDictionary* result = [REST_API postPath:[kRootURL stringByAppendingString:@"/php/loadDrops.php"] data:[JSONConverter convertNSMutableDictionaryToJSON:data]];
    return result;
}

+ (NSDictionary *) streamSong:(NSString*)song_id
{
    NSString* path = [[[kSCTrackURL stringByAppendingString:@"/"] stringByAppendingString:song_id] stringByAppendingString:@"/stream"];
    NSLog(@"path: %@", path);
    return [REST_API getPath:path];
}

+ (NSDictionary *)getTrackInfo:(NSString *)song_id
{
    return [REST_API getPath:[[[[kSCTrackURL stringByAppendingString:@"/"] stringByAppendingString:song_id] stringByAppendingString:@".json?client_id="] stringByAppendingString:kClientId] ];
}

+ (NSDictionary *) signIn:(NSMutableDictionary*)data
{
    NSDictionary* result = [REST_API postPath:[kRootURL stringByAppendingString:@"/php/mobileLogin.php"] data:[JSONConverter convertNSMutableDictionaryToJSON:data]];
    NSLog(@"result: %@", result);
    return result;
}

+ (NSDictionary *) dropSong:(NSMutableDictionary*)data
{
    NSDictionary* result = [REST_API postPath:[kRootURL stringByAppendingString:@"/php/mobileDrop.php"] data:[JSONConverter convertNSMutableDictionaryToJSON:data]];
    return result;
}

+ (NSDictionary *) getUserInfo:(NSString*)email
{
    NSDictionary* emailDict = [[NSDictionary alloc] initWithObjectsAndKeys:email, @"email", nil];
    NSDictionary* result = [REST_API postPath:[kRootURL stringByAppendingString:@"/php/mobileGetUserInfo.php"] data:[JSONConverter convertNSMutableDictionaryToJSON:emailDict]];
    return result;
}

@end
