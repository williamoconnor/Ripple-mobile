//
//  UIView+wboPlayerView.m
//  Ripple-App
//
//  Created by William O'Connor on 4/26/15.
//  Copyright (c) 2015 Gooey Dee Bee. All rights reserved.
//

#import "wboPlayerView.h"

@interface wboPlayerView()

- (void) togglePlayButton;
@property int hours;
@property int minutes;
@property int seconds;
@property NSDictionary* screen;

@end

@implementation wboPlayerView

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.screen = [[NSUserDefaults standardUserDefaults] objectForKey:@"screen"];
        
        self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.4];
        
        // TRACK NAME
        self.nowPlayingSongNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, [self.screen[@"width"] doubleValue], 40.0)];
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
        self.trackProgressSlider = [[UISlider alloc] initWithFrame:CGRectMake(75.0, 40.0, 0.75*[self.screen[@"width"] doubleValue], 20.0)];
        self.trackProgressSlider.minimumTrackTintColor = [UIColor colorWithRed:0x48/255.0 green:0x98/255.0 blue:0xBD/255.0 alpha:1.0];
        self.trackProgressSlider.maximumTrackTintColor = [UIColor colorWithRed:0xCC/255.0 green:0xCC/255.0 blue:0xCC/255.0 alpha:1.0];
        self.trackProgressSlider.continuous = YES;
        
        [self.trackProgressSlider setThumbImage:[UIImage imageNamed:@"rectangle.png"] forState:UIControlStateNormal];
        [self.trackProgressSlider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.trackProgressSlider];
        
        // TIME INDICATOR
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(35.0, 40.0, 37.5, 20.0)];
        self.timeLabel.font = [UIFont fontWithName:@"Poiret One" size:8];
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        self.timeLabel.textColor = [UIColor whiteColor];
        self.timeLabel.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.4];
        self.timeLabel.text = @"00 : 00";
        [self addSubview:self.timeLabel];
        [self bringSubviewToFront:self.timeLabel];
        
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

- (NSString*) convertSecondsToTimeString:(float)duration
{
    NSString* timeString;
    
    int hours = duration/(3600);
    int minutes = (duration - (3600)*hours)/60;
    int seconds = duration - ((3600)*hours) - (60*minutes);
    
    if (hours > 0) {
        timeString = [NSString stringWithFormat:@"%@:%@:%@", [self intToTimeString:hours], [self intToTimeString:minutes], [self intToTimeString:seconds]];
    }
    else {
        timeString = [NSString stringWithFormat:@"%@ : %@", [self intToTimeString:minutes], [self intToTimeString:seconds]];
    }
    
    return timeString;
}

- (void) setSongDuration:(float)duration
{
    NSString* time = [self convertSecondsToTimeString:duration];
    
    [self.timeLabel setText:time];
}

- (NSString*) intToTimeString:(int)timeInt
{
    NSString* timeString;
    
    if (timeInt < 10) {
        timeString = [NSString stringWithFormat:@"0%i", timeInt];
    }
    else {
        timeString = [NSString stringWithFormat:@"%i", timeInt];
    }
    
    return timeString;
}

@end
