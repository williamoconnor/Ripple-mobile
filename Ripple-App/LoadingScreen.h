//
//  LoadingScreen.h
//  Ripple+App
//
//  Created by William O'Connor on 12/18/16.
//  Copyright © 2016 Ripple, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoadingScreen : NSObject

+ (void)showLoadingDropsScreen;
+ (void)showDroppingScreen;
+ (void)hideLoadingDropsScreen;
+ (void)hideDroppingScreen;
+ (void)showGeneralLoadingScreen;
+ (void)hideGeneralLoadingScreen;


@end
