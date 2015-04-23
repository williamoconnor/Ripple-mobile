//
//  JSONConverter.m
//  Ripple-App
//
//  Created by William O'Connor on 4/19/15.
//  Copyright (c) 2015 Gooey Dee Bee. All rights reserved.
//

#import "JSONConverter.h"

@implementation JSONConverter

+ (NSString*)convertNSMutableDictionaryToJSON:(NSMutableDictionary *)dictionary
{
    // Initialize an error
    NSError *error;
    
    // Convert the dictionary to JSON
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
    
    // If JSON data, return it - else return an error
    if (jsonData) {
        return [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    }
    else {
        NSString *errorString = [@"JSON error: " stringByAppendingString:[error localizedDescription]];
        NSLog(@"%@", errorString);
        return errorString;
    }
}

+ (NSString*)convertNSDictionaryToJSON:(NSDictionary *)dictionary
{
    // Initialize an error
    NSError *error;
    
    // Convert the dictionary to JSON
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
    
    // If JSON data, return it - else return an error
    if (jsonData) {
        return [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    }
    else {
        NSString *errorString = [@"JSON error: " stringByAppendingString:[error localizedDescription]];
        NSLog(@"%@", errorString);
        return errorString;
    }
}

+ (NSDictionary*)convertNSDataToNSDictionary:(NSData *)data
{
    // Initialize an error
    NSError *error;
    
    // Convert the data to a dictionary
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    // If a string, return it - else return an error
    if (dictionary) {
        return dictionary;
    }
    else {
        NSString *errorString = [@"JSON error: " stringByAppendingString:[error localizedDescription]];
        NSLog(@"%@", errorString);
        return nil;
    }
}

+ (NSDictionary*)convertJSONToNSDictionary:(NSString *)jsonString
{
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    
    NSDictionary *menuDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    
    // If NSDictionary, return it - else return an error
    if(menuDictionary) {
        return menuDictionary;
    }
    else {
        NSLog(@"%@",error);
        return NULL;
    }
}


@end