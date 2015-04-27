//
//  ViewController.h
//  Ripple-App
//
//  Created by William O'Connor on 4/22/15.
//  Copyright (c) 2015 Gooey Dee Bee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import "wboPlayerView.h"

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate, CLLocationManagerDelegate, wboPlayerDelegate>

- (void) pauseButtonPressed;
- (void) playButtonPressed;

@end

