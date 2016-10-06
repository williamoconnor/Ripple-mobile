//
//  DataManager.m
//  Ripple-App
//
//  Created by William O'Connor on 4/19/15.
//  Copyright (c) 2015 Ripple. All rights reserved.
//

#import "DataManager.h"
#import "Strings.h"

@implementation DataManager

+ (NSDictionary *)getDrops:(NSMutableDictionary*)data
{
    NSDictionary* result = [REST_API getPath:[[kRootURL stringByAppendingString:kGetDrops] stringByAppendingString:[NSString stringWithFormat: @"?latitude=%@&longitude=%@", data[@"latitude"], data[@"longitude"]]]];
    return result;
}

+ (NSDictionary *) streamSong:(NSString*)song_id
{
    NSString* path = [[[kSCTrackURL stringByAppendingString:@"/"] stringByAppendingString:song_id] stringByAppendingString:@"/stream"];
    return [REST_API getPath:path];
}

+ (NSDictionary *)getTrackInfo:(NSString *)song_id
{
    return [REST_API getPath:[[[[kSCTrackURL stringByAppendingString:@"/"] stringByAppendingString:song_id] stringByAppendingString:@".json?client_id="] stringByAppendingString:kClientId] ];
}

+ (NSDictionary *) login:(NSMutableDictionary*)data
{
    NSDictionary* result = [REST_API postPath:[kRootURL stringByAppendingString:kLogin] data:[JSONConverter convertNSMutableDictionaryToJSON:data]];
    return result;
}

+ (NSDictionary *) dropSong:(NSMutableDictionary*)data
{
    NSDictionary* result = [REST_API postPath:[kRootURL stringByAppendingString:kCreateDrop] data:[JSONConverter convertNSMutableDictionaryToJSON:data]];
    return result;
}

+ (NSDictionary *) redropSong:(NSMutableDictionary*)data
{
    NSDictionary* result = [REST_API postPath:[kRootURL stringByAppendingString:kCreateDrop] data:[JSONConverter convertNSMutableDictionaryToJSON:data]];
    return result;
}

+ (NSDictionary *) getUserById:(NSString *)data
{
    NSDictionary* result = [REST_API getPath:[[kRootURL stringByAppendingString:kGetUser] stringByAppendingString:data]];
    return result;
}

+ (NSDictionary *) registerUser:(NSMutableDictionary*)data
{
    return [REST_API postPath:[kRootURL stringByAppendingString:kRegister] data:[JSONConverter convertNSMutableDictionaryToJSON:data]];
}

+ (NSDictionary *) getDropsForUser:(NSString *)data
{
    return [REST_API getPath:[[kRootURL stringByAppendingString: kGetDrops] stringByAppendingString:[NSString stringWithFormat:@"/%@", data]]];
}

+ (NSDictionary *) creditUser:(NSMutableDictionary *)data
{
    return [REST_API postPath:[kRootURL stringByAppendingString:kCredit] data:[JSONConverter convertNSMutableDictionaryToJSON:data]];
}

+ (NSDictionary *) searchSoundcloud:(NSString*)data
{
    return [REST_API getPath: [[kSCSearchRoute stringByReplacingOccurrencesOfString:@"YOURCLIENTID" withString:kClientId] stringByReplacingOccurrencesOfString:@"YOURQUERY" withString:data]];
}

@end
