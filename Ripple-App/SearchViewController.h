//
//  SearchViewController.h
//  Ripple-App
//
//  Created by William O'Connor on 9/7/15.
//  Copyright (c) 2015 Ripple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "PlayerViewController.h"
#import "NowPlayingFooter.h"
#import "songCell.h"

@protocol searchProtocol <NSObject>

-(void) returnHome;

@end

@interface SearchViewController : UIViewController <CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, rippleSongCellDelegate, NowPlayingFooterDelegate, PlayerDelegate, UISearchBarDelegate>


- (void) pauseButtonPressed;
- (void) playButtonPressed;

@property (strong, nonatomic) NSMutableArray* songIdsInFeed;
@property (nonatomic) id <searchProtocol> homeDelegate;

@property (strong, nonatomic)UIImageView* emptyContentView;

@end
