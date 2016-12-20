//
//  UIView+wboPlayerView.m
//  Ripple-App
//
//  Created by William O'Connor on 4/26/15.
//  Copyright (c) 2015 Ripple. All rights reserved.
//

#import "wboPlayerView.h"
#import "Rankings.h"
#import "Colors.h"
#import "LoadingScreen.h"

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
        
        self.backgroundColor = cWhite;
        
        // TRACK NAME
        self.nowPlayingSongNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 25, [self.screen[@"width"] doubleValue]-100.0, 25.0)];
        self.nowPlayingSongNameLabel.numberOfLines = 1;
        self.nowPlayingSongNameLabel.textColor = cPrimaryPink;
        self.nowPlayingSongNameLabel.font = [UIFont fontWithName:@"Avenir Next" size:20];
        self.nowPlayingSongNameLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview: self.nowPlayingSongNameLabel];
        
        // ARTIST NAME
        self.nowPlayingArtistNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 50, [self.screen[@"width"] doubleValue]-95.0, 30.0)];
        self.nowPlayingArtistNameLabel.numberOfLines = 1;
        self.nowPlayingArtistNameLabel.textColor = cPrimaryPink;
        self.nowPlayingArtistNameLabel.font = [UIFont fontWithName:@"Avenir Next" size:15];
        self.nowPlayingArtistNameLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview: self.nowPlayingArtistNameLabel];
        
        // PLAY BUTTON
        self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.playButton addTarget:self action:@selector(playButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        self.playButton.hidden = YES;
        self.playButton.frame = CGRectMake([self.screen[@"width"]doubleValue]/2 - 52.0, 72, 104.0, 104.0);
        [self.playButton setBackgroundImage:[UIImage imageNamed:@"Play.png"] forState:UIControlStateNormal];
        [self addSubview:self.playButton];
        
        // PAUSE BUTTON
        self.pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.pauseButton addTarget:self action:@selector(pauseButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        self.pauseButton.frame = CGRectMake([self.screen[@"width"]doubleValue]/2 - 52.0, 72, 104.0, 104.0);
        [self.pauseButton setBackgroundImage:[UIImage imageNamed:@"Pause.png"] forState:UIControlStateNormal];
        [self addSubview:self.pauseButton];
        
        // FORWARD BUTTON
        self.forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.forwardButton addTarget:self action:@selector(forwardButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        self.forwardButton.frame = CGRectMake(([self.screen[@"width"]doubleValue]/2)+90.0, 90, 69.0, 69.0);
        [self.forwardButton setBackgroundImage:[UIImage imageNamed:@"Next.png"] forState:UIControlStateNormal];
        [self addSubview:self.forwardButton];
        
        // BACKWARD BUTTON
        self.backwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.backwardButton addTarget:self action:@selector(backwardButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        self.backwardButton.frame = CGRectMake(([self.screen[@"width"]doubleValue]/2)-155, 90, 69.0, 69.0);
        [self.backwardButton setBackgroundImage:[UIImage imageNamed:@"Previous.png"] forState:UIControlStateNormal];
        [self addSubview:self.backwardButton];
        
        // DROP BUTTON
        // in its own method called by setTrack
        
        // DROPPED ICON
        // same
                
        // PROGRESS SLIDER
        self.trackProgressSlider = [[UISlider alloc] initWithFrame:CGRectMake(-2, 0, [self.screen[@"width"] doubleValue]+2, 3.0)];
        self.trackProgressSlider.minimumTrackTintColor = cPrimaryLightBlue;
        self.trackProgressSlider.maximumTrackTintColor = cWhite;
        self.trackProgressSlider.continuous = YES;
        CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 3.0f);
        self.trackProgressSlider.transform = transform;
        [self.trackProgressSlider setThumbImage:[[UIImage alloc] init] forState:UIControlStateNormal];
        
        [self.trackProgressSlider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.trackProgressSlider];
        
        // TIME INDICATOR - Front
        self.frontTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 8.0, 37.5, 20.0)];
        self.frontTimeLabel.font = [UIFont fontWithName:@"Avenir Next" size:10];
        self.frontTimeLabel.textAlignment = NSTextAlignmentCenter;
        self.frontTimeLabel.textColor = cPrimaryLightBlue;
        self.frontTimeLabel.text = @"00 : 00";
        [self addSubview:self.frontTimeLabel];
        [self bringSubviewToFront:self.frontTimeLabel];
        
        // TIME INDICATOR - End
        self.backTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake([self.screen[@"width"] floatValue] - 40, 8.0, 37.5, 20.0)];
        self.backTimeLabel.font = [UIFont fontWithName:@"Avenir Next" size:10];
        self.backTimeLabel.textAlignment = NSTextAlignmentCenter;
        self.backTimeLabel.textColor = cPrimaryLightBlue;
        self.backTimeLabel.text = @"-- : --";
        [self addSubview:self.backTimeLabel];
        [self bringSubviewToFront:self.backTimeLabel];
    }
    return self;
}

-(void) drop
{
    NSLog(@"Track: %@", self.track);
    [LoadingScreen showDroppingScreen];
    double delayInSeconds = 0.01;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        BOOL success = [self.delegate drop:self.dropType andTrack:self.track];
        if (success == YES) {
            [self setCheckmark];
        }
    });
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

- (void) setSongProgress:(float)progress andDuration:(float)duration
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

-(void) enableButtons:(BOOL)enable
{
    float alpha = 0.2;
    if (enable == YES) {
        alpha = 1;
    }
    self.pauseButton.alpha = alpha;
    self.pauseButton.userInteractionEnabled = enable;
    // [self.pauseButton setEnabled:enable];
    self.forwardButton.alpha = alpha;
    self.forwardButton.userInteractionEnabled = enable;
    // [self.forwardButton setEnabled:enable];
    self.backwardButton.alpha = alpha;
    self.backwardButton.userInteractionEnabled = enable;
    // [self.backwardButton setEnabled:enable];
    [self.trackProgressSlider setEnabled:enable];

}

-(void)setTrack:(NSDictionary *)track
{
    // set drop button
    // determine if checkmark
    _track = track;
    NSDictionary* user = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    if ([self.dropType isEqualToString: @"drop" ] || ([self.dropType isEqualToString: @"redrop"] && ![track[@"previous_dropper_ids"] containsObject:user[@"_id"]]) ) {
        [self createDropButton];
    }
    else {
        [self setCheckmark];
    }
}

-(void)setCheckmark
{
    self.dropped = YES;
    [self.droppedIcon removeFromSuperview];
    [self.dropButton removeFromSuperview];
    self.droppedIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"checkmark-%@.png", [Rankings getRankingToColorString:[self.track[@"rank"] intValue]]]]];
    self.droppedIcon.frame = CGRectMake(([self.screen[@"width"]doubleValue]/2)+116.0, 35.0, 30.0, 30.0);
    [self addSubview:self.droppedIcon];
}

-(void)createDropButton
{
    self.dropped = NO;
    [self.dropButton removeFromSuperview];
    [self.droppedIcon removeFromSuperview];
    self.dropButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.dropButton.frame = CGRectMake(([self.screen[@"width"]doubleValue]/2)+104.0, 31.0, 44.0, 44.0);
    [self.dropButton addTarget:self
                        action:@selector(drop)
              forControlEvents:UIControlEventTouchUpInside];
    
    NSString* imageName = [NSString stringWithFormat:@"%@-drop-outline-large.png", [Rankings getRankingToColorString:[self.track[@"rank"] intValue]]];
    [self.dropButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    
    //self.titleLabel.frame = CGRectMake(120.0, 10.0, [self.screen[@"width"] doubleValue]*0.48, 60.0);
    [self addSubview:self.dropButton];
}

@end
