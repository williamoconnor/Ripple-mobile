//
//  HexColor.h
//  Buyers Marque
//
//  Created by William O'Connor on 1/18/16.
//  Copyright © 2016 HundredDollaBill Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HexColor : NSObject

+(UIColor*) colorWithHexString:(NSString*)hex;

@end
