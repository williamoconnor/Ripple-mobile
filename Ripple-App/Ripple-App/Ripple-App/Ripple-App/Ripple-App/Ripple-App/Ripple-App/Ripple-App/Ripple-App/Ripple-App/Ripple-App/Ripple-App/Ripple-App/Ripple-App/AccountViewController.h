//
//  AccountViewController.h
//  Ripple-App
//
//  Created by William O'Connor on 5/1/15.
//  Copyright (c) 2015 Ripple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "PlayerViewController.h"
#import "NowPlayingFooter.h"
#import "songCell.h"

@interface AccountViewController : UIViewController <CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, rippleSongCellDelegate, NowPlayingFooterDelegate, PlayerDelegate>

- (void) pauseButtonPressed;
- (void) playButtonPressed;

@end
