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

-(void) setSongInfo:(NSDictionary*)info;
-(void) songChanged:(NSDictionary*)info;
-(void) keepVC:(id)player;

@end

@interface PlayerViewController : UIViewController <wboPlayerDelegate, AVAudioPlayerDelegate>

@property (strong, nonatomic) wboPlayerView* playerGui;
@property (strong, nonatomic) NSDictionary* song;
@property (strong, nonatomic) NSMutableArray *tracks;
@property NSInteger nowPlayingTrackIndex;
@property (strong, nonatomic) NSMutableArray *albumCovers;
@property (nonatomic, strong) AVAudioPlayer *player;
@property NSTimer *timer;
-(void) playSong;
- (NSMutableDictionary*) getSongInfo;
@property (nonatomic) id <PlayerDelegate> delegate;

@end
