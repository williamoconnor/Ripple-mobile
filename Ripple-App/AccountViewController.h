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
#import "accountStatusHeader.h"

@interface AccountViewController : UIViewController <CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, rippleSongCellDelegate, NowPlayingFooterDelegate, PlayerDelegate, statusHeaderDelegate>

@property (strong, nonatomic)accountStatusHeader* statusHeader;
@property (strong, nonatomic)UIImageView* emptyContentView;

@end
