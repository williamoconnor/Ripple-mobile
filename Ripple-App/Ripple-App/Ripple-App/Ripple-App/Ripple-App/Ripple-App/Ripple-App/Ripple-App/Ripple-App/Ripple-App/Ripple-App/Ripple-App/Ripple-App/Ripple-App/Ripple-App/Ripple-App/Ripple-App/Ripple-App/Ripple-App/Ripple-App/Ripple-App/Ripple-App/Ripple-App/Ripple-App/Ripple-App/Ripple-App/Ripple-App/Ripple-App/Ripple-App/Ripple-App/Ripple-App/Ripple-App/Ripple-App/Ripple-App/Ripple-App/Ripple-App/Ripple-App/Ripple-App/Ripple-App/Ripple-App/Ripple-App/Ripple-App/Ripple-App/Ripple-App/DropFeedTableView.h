//
//  dropFeedTableView.h
//  Ripple-App
//
//  Created by William O'Connor on 9/6/15.
//  Copyright (c) 2015 Ripple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DropFeedTableView : UITableView

- (id)initWithFrame:(CGRect)frame andTracks:(NSMutableArray*) tracks andAlbumCovers:(NSMutableArray*) albumCovers;
- (void) highlightCell;

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *tracks;
@property (strong, nonatomic) NSMutableArray *albumCovers;
@property (strong, nonatomic) UIActivityIndicatorView* loading;
@property NSInteger nowPlayingTrackIndex;

@end
