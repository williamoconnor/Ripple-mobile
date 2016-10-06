//
//  AppDelegate.h
//  Ripple-App
//
//  Created by William O'Connor on 4/22/15.
//  Copyright (c) 2015 Ripple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "NowPlayingFooter.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, AVAudioPlayerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) AVAudioPlayer* player;
@property (strong, nonatomic) NowPlayingFooter* footer;

@end

