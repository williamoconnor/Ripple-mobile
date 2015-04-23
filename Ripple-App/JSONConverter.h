//
//  JSONConverter.h
//  Ripple-App
//
//  Created by William O'Connor on 4/19/15.
//  Copyright (c) 2015 Gooey Dee Bee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONConverter : NSObject

+ (NSString *)convertNSMutableDictionaryToJSON:(NSMutableDictionary *)dictionary;
+ (NSString*)convertNSDictionaryToJSON:(NSDictionary *)dictionary;
+ (NSDictionary*)convertNSDataToNSDictionary:(NSData *)data;
+ (NSMutableDictionary *)convertJSONToNSDictionary:(NSString *)json;

@end
