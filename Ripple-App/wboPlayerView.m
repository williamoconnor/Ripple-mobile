//
//  UIView+wboPlayerView.m
//  Ripple-App
//
//  Created by William O'Connor on 4/26/15.
//  Copyright (c) 2015 Gooey Dee Bee. All rights reserved.
//

#import "wboPlayerView.h"

@interface wboPlayerView()

@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) UIButton *pauseButton;

- (void) togglePlayButton;

@end

@implementation wboPlayerView

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.4];
        
        // TRACK NAME
        self.nowPlayingSongNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 375.0, 40.0)];
        self.nowPlayingSongNameLabel.textColor = [UIColor whiteColor];
        self.nowPlayingSongNameLabel.font = [UIFont fontWithName:@"Poiret One" size:18];
        self.nowPlayingSongNameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview: self.nowPlayingSongNameLabel];
        
        // PLAY BUTTON
        self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.playButton addTarget:self action:@selector(playButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        self.playButton.hidden = YES;
        self.playButton.frame = CGRectMake(10.0, 40.0, 20.0, 20.0);
        [self.playButton setBackgroundImage:[UIImage imageNamed:@"whitePlay.png"] forState:UIControlStateNormal];
        [self addSubview:self.playButton];
        
        // PAUSE BUTTON
        self.pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.pauseButton addTarget:self action:@selector(pauseButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        self.pauseButton.frame = CGRectMake(10.0, 40.0, 20.0, 20.0);
        [self.pauseButton setBackgroundImage:[UIImage imageNamed:@"whitePause.png"] forState:UIControlStateNormal];
        [self addSubview:self.pauseButton];
        
        // PROGRESS SLIDER
        self.trackProgressSlider = [[UISlider alloc] initWithFrame:CGRectMake(40.0, 40.0, 315.0, 20.0)];
        self.trackProgressSlider.minimumTrackTintColor = [UIColor colorWithRed:0x48/255.0 green:0x98/255.0 blue:0xBD/255.0 alpha:1.0];
        self.trackProgressSlider.maximumTrackTintColor = [UIColor colorWithRed:0xCC/255.0 green:0xCC/255.0 blue:0xCC/255.0 alpha:1.0];
        self.trackProgressSlider.continuous = YES;
        
        [self.trackProgressSlider setThumbImage:[UIImage imageNamed:@"circle.png"] forState:UIControlStateNormal];
        [self.trackProgressSlider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.trackProgressSlider];
        
    }
    return self;
}

- (void) playButtonPressed
{
    [self togglePlayButton];
    [self.delegate playButtonPressed];
}

- (void) pauseButtonPressed
{
    [self togglePlayButton];
    [self.delegate pauseButtonPressed];
}

- (void) sliderValueChanged
{
    NSLog(@"%f", self.trackProgressSlider.value);  // it registers
    [self.trackProgressSlider setValue:self.trackProgressSlider.value animated:YES];
    [self.delegate navigateInSong:self.trackProgressSlider.value];
}

- (void) togglePlayButton
{
    if (self.playButton.hidden == YES) {
        self.playButton.hidden = NO;
        self.pauseButton.hidden = YES;
    }
    else {
        self.playButton.hidden = YES;
        self.pauseButton.hidden = NO;
    }
}

@end
