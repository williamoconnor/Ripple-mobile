//
//  UIView+wboPlayerView.h
//  Ripple-App
//
//  Created by William O'Connor on 4/26/15.
//  Copyright (c) 2015 Ripple. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol wboPlayerDelegate <NSObject>

- (void) pauseButtonPressed;
- (void) playButtonPressed;
- (void) backwardPressed;
- (void) forwardPressed;
- (void) navigateInSong:(float) newTime;
- (BOOL) drop:(NSString*)type andTrack:(NSDictionary*)track;

@end

@interface wboPlayerView: UIView

//@property (strong, nonatomic) UIView* playerBackground;
@property (strong, nonatomic) UILabel* nowPlayingSongNameLabel;
@property (strong, nonatomic) UILabel* nowPlayingArtistNameLabel;
@property (weak, nonatomic) id <wboPlayerDelegate> delegate;
@property (strong, nonatomic) UISlider *trackProgressSlider;
@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) UIButton *pauseButton;
@property (strong, nonatomic) UIButton *forwardButton;
@property (strong, nonatomic) UIButton *backwardButton;
@property (strong, nonatomic) UIButton *dropButton;
@property (strong, nonatomic) UIImageView *droppedIcon;
@property (strong, nonatomic) UILabel *frontTimeLabel;
@property (strong, nonatomic) UILabel *backTimeLabel;

@property (strong, nonatomic) NSDictionary* track;
@property (strong, nonatomic) NSString* dropType;
@property BOOL dropped;

- (void) resetProgress;
- (void) setSongProgress: (float)progress andDuration: (float)duration;
- (void) togglePlayButton;
- (void) enableButtons:(BOOL)enable;
-(void)setCheckmark;
-(void)createDropButton;


@end
