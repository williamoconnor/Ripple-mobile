//
//  REST_API.m
//  Ripple-App
//
//  Created by William O'Connor on 4/19/15.
//  Copyright (c) 2015 Gooey Dee Bee. All rights reserved.
//

#import "REST_API.h"

// Hidden methods interface
@interface REST_API (hidden)

+ (NSDictionary*)sendRequest:(NSMutableURLRequest*)request;

@end

// Hidden methods implementation
@implementation REST_API (hidden)

+ (NSDictionary*)sendRequest:(NSMutableURLRequest*)request
{
    NSHTTPURLResponse* urlResponse = nil;
    NSError *error = [[NSError alloc] init];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    
    if ([urlResponse statusCode] >= 200 && [urlResponse statusCode] < 300) {
        // Convert data to JSON string
        return [JSONConverter convertNSDataToNSDictionary:responseData];
    }
    else {
        // Error in request - return nil and log the error
        NSLog(@"Response Code: %ld. Please see PHP error log for more information.", (long)[urlResponse statusCode]);
        return  nil;
    }
}

@end

// Public implementation
@implementation REST_API

+ (NSDictionary*)getPath:(NSString*)resource
{
    // Create the link that will be used for the request
    NSURL *nsurl = [NSURL URLWithString:[[NSString stringWithFormat:@"%@", resource] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    // Create the request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:nsurl];
    
    // Set the request type to GET
    [request setHTTPMethod:@"GET"];
    
    // Return the results of the request
    return [self sendRequest:request];
}

+ (NSDictionary *)postPath:(NSString*)resource data:(NSString*)dataString
{
    // Create the link that will be used for the request
    NSURL *nsurl = [NSURL URLWithString:[[NSString stringWithFormat:@"%@", resource] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    // Create the request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:nsurl];
    
    // Set the request type to POST
    [request setHTTPMethod:@"POST"];
    
    // Convert the information to post to NSData
    NSData *postData = [dataString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    // Set the values to the HTTP body
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    // Return the results of the request
    return [self sendRequest:request];
}

+ (NSDictionary *)putPath:(NSString*)resource data:(NSString*)dataString
{
    // Create the link that will be used for the request
    NSURL *nsurl = [NSURL URLWithString:[[NSString stringWithFormat:@"%@", resource] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    // Create the request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:nsurl];
    
    // Set the request type to PUT
    [request setHTTPMethod:@"PUT"];
    
    // Convert the information to post to NSData
    NSData *putData = [dataString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *putLength = [NSString stringWithFormat:@"%lu", (unsigned long)[putData length]];
    
    // Set the values to the HTTP body
    [request setValue:putLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:putData];
    
    // Return the results of the request
    return [self sendRequest:request];
}

+ (bool)testConnection:(NSString*)resource
{
    // Create the link that will be used for the request
    NSURL *nsurl = [NSURL URLWithString:[[NSString stringWithFormat:@"%@", resource] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    // Create the request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:nsurl];
    
    // Set the request type to GET
    [request setHTTPMethod:@"GET"];
    
    NSHTTPURLResponse* urlResponse = nil;
    NSError *error = [[NSError alloc] init];
    [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    
    if ([urlResponse statusCode] >= 200 && [urlResponse statusCode] < 300) {
        return true;
    }
    else {
        // Error in request - return nil and log the error
        NSLog(@"Response Code: %ld", (long)[urlResponse statusCode]);
        NSLog(@"%@", [error localizedDescription]);
        return  false;
    }
}

@end
