//
//  PlayerViewController.h
//  Ripple-App
//
//  Created by William O'Connor on 6/10/15.
//  Copyright (c) 2015 Ripple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "wboPlayerView.h"

@protocol PlayerDelegate <NSObject>

-(void) showFooter;
-(void) updateTrackIndex:(int)index;
- (BOOL) drop:(NSString*)type andTrack:(NSDictionary*)track;

@end

@interface PlayerViewController : UIViewController <wboPlayerDelegate, AVAudioPlayerDelegate>

@property (strong, nonatomic) wboPlayerView* playerGui;
@property (nonatomic) id <PlayerDelegate> delegate;

@property (strong, nonatomic) NSMutableArray *tracks;
@property (strong, nonatomic) NSMutableArray *albumCovers;
@property NSInteger nowPlayingTrackIndex;

@property (nonatomic, strong) AVAudioPlayer *player;
@property NSTimer *timer;

-(void)playSongAtIndex:(int)index inTracks:tracks withAlbumCovers:(NSArray*)albumCovers;
-(void)initUI;
-(void)initData;

// managing drop
@property BOOL dropped;
- (BOOL) drop:(NSString*)type andTrack:(NSDictionary*)track;

@end
