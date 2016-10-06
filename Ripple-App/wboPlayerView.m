//
//  UIView+wboPlayerView.m
//  Ripple-App
//
//  Created by William O'Connor on 4/26/15.
//  Copyright (c) 2015 Ripple. All rights reserved.
//

#import "wboPlayerView.h"
#import "Colors.h"

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
        
        self.backgroundColor = cSlateNavy;
        
        // TRACK NAME
        self.nowPlayingSongNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 0.0, [self.screen[@"width"] doubleValue]-40.0, 80.0)];
        self.nowPlayingSongNameLabel.numberOfLines = 0;
        self.nowPlayingSongNameLabel.textColor = [UIColor whiteColor];
        self.nowPlayingSongNameLabel.font = [UIFont fontWithName:@"Poiret One" size:18];
        self.nowPlayingSongNameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview: self.nowPlayingSongNameLabel];
        
        // PLAY BUTTON
        self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.playButton addTarget:self action:@selector(playButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        self.playButton.hidden = YES;
        self.playButton.frame = CGRectMake([self.screen[@"width"]doubleValue]/2 - 20.0, 80.0, 40.0, 40.0);
        [self.playButton setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        [self addSubview:self.playButton];
        
        // PAUSE BUTTON
        self.pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.pauseButton addTarget:self action:@selector(pauseButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        self.pauseButton.frame = CGRectMake([self.screen[@"width"]doubleValue]/2 - 20.0, 80.0, 40.0, 40.0);
        [self.pauseButton setBackgroundImage:[UIImage imageNamed:@"whitePause.png"] forState:UIControlStateNormal];
        [self addSubview:self.pauseButton];
        
        // FORWARD BUTTON
        self.forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.forwardButton addTarget:self action:@selector(forwardButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        self.forwardButton.frame = CGRectMake([self.screen[@"width"]doubleValue]-80.0, 80.0, 40.0, 40.0);
        [self.forwardButton setBackgroundImage:[UIImage imageNamed:@"forward.png"] forState:UIControlStateNormal];
        [self addSubview:self.forwardButton];
        
        // BACKWARD BUTTON
        self.backwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.backwardButton addTarget:self action:@selector(backwardButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        self.backwardButton.frame = CGRectMake(40.0, 80.0, 40.0, 40.0);
        [self.backwardButton setBackgroundImage:[UIImage imageNamed:@"backward.png"] forState:UIControlStateNormal];
        [self addSubview:self.backwardButton];
        
        // PROGRESS SLIDER
        self.trackProgressSlider = [[UISlider alloc] initWithFrame:CGRectMake(0.125*[self.screen[@"width"] doubleValue], 140.0, 0.75*[self.screen[@"width"] doubleValue], 20.0)];
        self.trackProgressSlider.minimumTrackTintColor = cPrimaryRed;
        self.trackProgressSlider.maximumTrackTintColor = [UIColor colorWithRed:0xCC/255.0 green:0xCC/255.0 blue:0xCC/255.0 alpha:1.0];
        self.trackProgressSlider.continuous = YES;
        
        [self.trackProgressSlider setThumbImage:[UIImage imageNamed:@"rectangle.png"] forState:UIControlStateNormal];
        [self.trackProgressSlider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.trackProgressSlider];
        
        // TIME INDICATOR - Front
        self.frontTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.125*[self.screen[@"width"] doubleValue]-18.75, 160.0, 37.5, 20.0)];
        self.frontTimeLabel.font = [UIFont fontWithName:@"Poiret One" size:8];
        self.frontTimeLabel.textAlignment = NSTextAlignmentCenter;
        self.frontTimeLabel.textColor = [UIColor whiteColor];
        self.frontTimeLabel.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.4];
        self.frontTimeLabel.text = @"00 : 00";
        [self addSubview:self.frontTimeLabel];
        [self bringSubviewToFront:self.frontTimeLabel];
        
        // TIME INDICATOR - End
        self.backTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.875*[self.screen[@"width"] floatValue] - 18.75, 160.0, 37.5, 20.0)];
        self.backTimeLabel.font = [UIFont fontWithName:@"Poiret One" size:8];
        self.backTimeLabel.textAlignment = NSTextAlignmentCenter;
        self.backTimeLabel.textColor = [UIColor whiteColor];
        self.backTimeLabel.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.4];
        self.backTimeLabel.text = @"-- : --";
        [self addSubview:self.backTimeLabel];
        [self bringSubviewToFront:self.backTimeLabel];
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

-(void) forwardButtonPressed
{
    [self.delegate forwardPressed];
}

-(void) backwardButtonPressed
{
    [self.delegate backwardPressed];
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

- (void) setSongDuration:(float)progress andDuration:(float)duration
{
    NSString* frontTime = [self convertSecondsToTimeString:progress];
    NSString* backTime = [self convertSecondsToTimeString:(duration-progress)];
    
    [self.frontTimeLabel setText:frontTime];
    [self.backTimeLabel setText:[NSString stringWithFormat:@"-%@", backTime]];
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

-(void) resetProgress
{
    self.frontTimeLabel.text = @"00 : 00";
    [self.trackProgressSlider setValue:0.0];
}

-(void) disableEnableButtons:(BOOL)enable
{
    UIViewTintAdjustmentMode mode = UIViewTintAdjustmentModeDimmed;
    if (enable == NO) {
        mode = UIViewTintAdjustmentModeNormal;
    }
    [self.pauseButton setTintAdjustmentMode:mode];
    [self.pauseButton setEnabled:enable];
    [self.forwardButton setTintAdjustmentMode:mode];
    [self.forwardButton setEnabled:enable];
    [self.backwardButton setTintAdjustmentMode:mode];
    [self.backwardButton setEnabled:enable];
    [self.trackProgressSlider setEnabled:enable];
}

@end
