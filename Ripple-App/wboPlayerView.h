//
//  UIView+wboPlayerView.h
//  Ripple-App
//
//  Created by William O'Connor on 4/26/15.
//  Copyright (c) 2015 Gooey Dee Bee. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol wboPlayerDelegate <NSObject>

- (void) pauseButtonPressed;
- (void) playButtonPressed;
- (void) navigateInSong:(float) newTime;

@end

@interface wboPlayerView: UIView

//@property (strong, nonatomic) UIView* playerBackground;
@property (strong, nonatomic) UILabel* nowPlayingSongNameLabel;
@property (weak, nonatomic) id <wboPlayerDelegate> delegate;
@property (strong, nonatomic) UISlider *trackProgressSlider;
@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) UIButton *pauseButton;
@property (strong, nonatomic) UILabel *timeLabel;
- (void) setSongDuration: (float)duration;
- (void) togglePlayButton;


@end
