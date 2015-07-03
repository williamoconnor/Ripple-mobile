//
//  ViewController.h
//  Ripple-App
//
//  Created by William O'Connor on 4/22/15.
//  Copyright (c) 2015 Gooey Dee Bee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CoreLocation/CoreLocation.h>
#import "wboPlayerView.h"
#import "songCell.h"
#import "NowPlayingFooter.h"
#import "PlayerViewController.h"

@interface ListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate, CLLocationManagerDelegate, rippleSongCellDelegate, NowPlayingFooterDelegate, PlayerDelegate>

extern NSMutableDictionary* screenSize;

- (void) pauseButtonPressed;
- (void) playButtonPressed;

@end

