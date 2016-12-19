//
//  LoadingScreen.m
//  Ripple-App
//
//  Created by William O'Connor on 12/18/16.
//  Copyright © 2016 Ripple, LLC. All rights reserved.
//

#import "LoadingScreen.h"
#import "LoadingDropsScreen.h"
#import "DroppingLoadingScreen.h"
#import "GeneralLoadingScreen.h"
#import "Screen.h"


@implementation LoadingScreen

+ (void)showLoadingDropsScreen
{
    [self hideLoadingDropsScreen];
    LoadingDropsScreen* loadingScreen = [[LoadingDropsScreen alloc] initWithFrame:CGRectMake(0, 0, [[Screen screenDimensions][@"width"] floatValue], [[Screen screenDimensions][@"height"] floatValue])];
    loadingScreen.alpha = 0;
    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
    [currentWindow addSubview:loadingScreen];
    
    [UIView animateWithDuration:0.2 animations:^{
        loadingScreen.alpha = 1;
    }];
}

+ (void)showDroppingScreen
{
    [self hideDroppingScreen];
    DroppingLoadingScreen* loadingScreen = [[DroppingLoadingScreen alloc] initWithFrame:CGRectMake(0, 0, [[Screen screenDimensions][@"width"] floatValue], [[Screen screenDimensions][@"height"] floatValue])];
    loadingScreen.alpha = 0;
    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
    [currentWindow addSubview:loadingScreen];
    
    [UIView animateWithDuration:0.2 animations:^{
        loadingScreen.alpha = 1;
    }];
}

+ (void)showGeneralLoadingScreen
{
    [self hideDroppingScreen];
    GeneralLoadingScreen* loadingScreen = [[GeneralLoadingScreen alloc] initWithFrame:CGRectMake(0, 0, [[Screen screenDimensions][@"width"] floatValue], [[Screen screenDimensions][@"height"] floatValue])];
    loadingScreen.alpha = 0;
    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
    [currentWindow addSubview:loadingScreen];
    
    [UIView animateWithDuration:0.2 animations:^{
        loadingScreen.alpha = 1;
    }];
}

+ (void)hideLoadingDropsScreen
{
    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
    LoadingDropsScreen* loadingScreen;
    for (UIView* view in currentWindow.subviews) {
        if ([view isKindOfClass:[LoadingDropsScreen class]]) {
            loadingScreen = (LoadingDropsScreen*)view;
            break;
        }
    }
    [UIView animateWithDuration:0.2 animations:^{
        loadingScreen.alpha = 0;
    } completion:^(BOOL finished) {
        [loadingScreen removeFromSuperview];
    }];
}
+ (void)hideDroppingScreen
{
    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
    DroppingLoadingScreen* loadingScreen;
    for (UIView* view in currentWindow.subviews) {
        if ([view isKindOfClass:[DroppingLoadingScreen class]]) {
            loadingScreen = (DroppingLoadingScreen*)view;
            break;
        }
    }
    [UIView animateWithDuration:0.2 animations:^{
        loadingScreen.alpha = 0;
    } completion:^(BOOL finished) {
        [loadingScreen removeFromSuperview];
    }];
}

+ (void)hideGeneralLoadingScreen
{
    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
    GeneralLoadingScreen* loadingScreen;
    for (UIView* view in currentWindow.subviews) {
        if ([view isKindOfClass:[GeneralLoadingScreen class]]) {
            loadingScreen = (GeneralLoadingScreen*)view;
            break;
        }
    }
    [UIView animateWithDuration:0.2 animations:^{
        loadingScreen.alpha = 0;
    } completion:^(BOOL finished) {
        [loadingScreen removeFromSuperview];
    }];
}

@end
