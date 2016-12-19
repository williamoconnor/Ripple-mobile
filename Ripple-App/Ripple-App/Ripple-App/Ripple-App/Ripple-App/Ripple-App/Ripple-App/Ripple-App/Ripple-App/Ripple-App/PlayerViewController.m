//
//  PlayerViewController.m
//  Ripple-App
//
//  Created by William O'Connor on 6/10/15.
//  Copyright (c) 2015 Ripple. All rights reserved.
//

#import "PlayerViewController.h"
#import "wboPlayerView.h"
#import "Strings.h"
#import "SCUI.h"
#import "AppDelegate.h"
#import "Colors.h"

@interface PlayerViewController ()

@property (strong, nonatomic) UIImageView *albumCover;
@property (strong, nonatomic) UIButton* backButton;
@property (strong, nonatomic) UIActivityIndicatorView* loading;

// TIMER
@property int time;
- (void) clock;
- (void) startTimer;
- (void) countup;
- (void) updateSlider;

@end

@implementation PlayerViewController

-(AppDelegate*) app
{
    return (AppDelegate*) [[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    NSNumber *height = [[NSNumber alloc] initWithDouble:screenHeight];
    NSNumber *width = [[NSNumber alloc] initWithDouble:screenWidth];
    
    self.view.backgroundColor = cSlateNavy;
    
    //FAKE NAV BAR
    UIView* fakeNavBar = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, [width floatValue], 64.0)];
    fakeNavBar.backgroundColor = cPrimaryPink;
    [self.view addSubview:fakeNavBar];
    
    //BACK BUTTON
    self.backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.backButton.frame = CGRectMake(12.0, 32.0, 50.0, 21.0);
    [self.backButton setTintColor:[UIColor whiteColor]];
    [self.backButton setTitle:@"Back" forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.backButton.titleLabel.font = [UIFont fontWithName:@"Avenir Next" size:17];
    [fakeNavBar addSubview:self.backButton];
    
    //NAV TITLE
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake([width floatValue]/2 - 72.5, 18.0, 145.0, 40.0)];
    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont fontWithName:@"Avenir" size:32.0], NSFontAttributeName,
                                cWhite, NSForegroundColorAttributeName,
                                nil];
    NSMutableAttributedString* navTitle = [[NSMutableAttributedString alloc] initWithString:@"ripple" attributes:attributes];
    [navTitle addAttribute:NSKernAttributeName
                     value:@(4.9)
                     range:NSMakeRange(0, 5)];
    titleLabel.attributedText = navTitle;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [fakeNavBar addSubview:titleLabel];
    
    //ALBUM COVER
    self.albumCover = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 64.0, [width floatValue], [width floatValue])];
    [self.view addSubview:self.albumCover];
    [self loadAlbumCover];
    
    //GUI - dont forget to make a small thing to get back here on the list view
    self.playerGui = [[wboPlayerView alloc] initWithFrame:CGRectMake(0.0, (64 + [width floatValue]), [width floatValue], [height floatValue]-(64 + [width floatValue]))];
    self.playerGui.delegate = self;
    [self.view addSubview:self.playerGui];
    [self.playerGui disableEnableButtons:NO];
    
// ACTIVITY INDICATOR
    self.loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    double x = [width doubleValue]/2;
    self.loading.center = CGPointMake(x, 160.0);
    self.loading.hidesWhenStopped = YES;
    [self.view addSubview:self.loading];
    [self.view bringSubviewToFront:self.loading];
    
// NAV BAR
//    self.navigationController.navigationBar.barTintColor = cPrimaryPink;
//    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:
//                                [UIFont fontWithName:@"Avenir" size:36.0], NSFontAttributeName,
//                                cWhite, NSForegroundColorAttributeName,
//                                nil];
//    NSMutableAttributedString* navTitle = [[NSMutableAttributedString alloc] initWithString:@"ripple" attributes:attributes];
//    [navTitle addAttribute:NSKernAttributeName
//                     value:@(4.9)
//                     range:NSMakeRange(0, 5)];
//    UILabel* navTitleLabel = [[UILabel alloc] init];
//    navTitleLabel.attributedText = navTitle;
//    [navTitleLabel sizeToFit];
//    self.navigationItem.titleView = navTitleLabel;
//    NSLog(@"here da song %@", self.song);
    self.playerGui.nowPlayingSongNameLabel.text = self.song[@"name"];
    //[self playSong];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //disable buttons
    if (![self app].player.duration > 0) {
        [self.playerGui disableEnableButtons:NO];
    }
}

- (void) loadAlbumCover
{
    UIImage *albumCoverImage = [[UIImage alloc] init];
    if (![self.song[@"artwork_url"] isEqual:[NSNull null]] && [self.song[@"artwork_url"] length] > 0){
        NSString* url = [self.song[@"artwork_url"] stringByReplacingOccurrencesOfString:@"large"                                                        withString:@"crop"];
        albumCoverImage = [UIImage imageWithData:
                           [NSData dataWithContentsOfURL:
                            [NSURL URLWithString: url]]];
    }
    else {
        albumCoverImage = [UIImage imageNamed:@"logo-text-under-drop"];
    }
    self.albumCover.contentMode = UIViewContentModeScaleAspectFit;
    self.albumCover.image = albumCoverImage;
}

-(void) playSong
{
    
    NSURL *trackURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.soundcloud.com/tracks/%@/stream?client_id=%@", self.song[@"soundcloud_track_id"], kClientId]];
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:trackURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"RESP: %@", response);
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
        if ((long)[httpResponse statusCode] >= 400) {
            [self playNextSong];
        }
        else {
            if (error) {
                NSLog(@"error: %@", error);
            }
            
            
            //        while (data.length < 100) {
            //            data = [NSData dataWithContentsOfURL:trackURL];
            //        }

            [self app].player = nil;
            [self app].player = [[AVAudioPlayer alloc] initWithData:data error:nil];
            
            
            //get your app's audioSession singleton object
            AVAudioSession* session = [AVAudioSession sharedInstance];
            
            //error handling
            BOOL success;
            NSError* session_error;
            
            //set the audioSession category.
            //Needs to be Record or PlayAndRecord to use audioRouteOverride:
            
            success = [session setCategory:AVAudioSessionCategoryPlayback
                                     error:&session_error];
            
            if (!success)  NSLog(@"AVAudioSession error setting category:%@",session_error);
            
            //set the audioSession override
            //        success = [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker
            //                                             error:&error];
            // if (!success)  NSLog(@"AVAudioSession error overrideOutputAudioPort:%@",session_error);
            
            //activate the audio session
            success = [session setActive:YES error:&session_error];
            if (!success) NSLog(@"AVAudioSession error activating: %@",session_error);
            else NSLog(@"audioSession active");
            [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
            
            //        NSLog(@"url: %@", trackURL);
            [[self app].player play];
            
            // TRACK PROGRESS
            UIImage *albumArtImg = self.albumCovers[self.nowPlayingTrackIndex];
            MPMediaItemArtwork* albumArt = [[MPMediaItemArtwork alloc] initWithImage:albumArtImg];
            [self startTimer];
            
            self.playerGui.trackProgressSlider.maximumValue = [self app].player.duration;
            self.playerGui.trackProgressSlider.minimumValue = 0;
            NSMutableDictionary* songInfo = [[NSMutableDictionary alloc] init];
            songInfo[@"song"] = self.song[@"name"];
            songInfo[@"album"] = albumArtImg;
            [self.delegate setSongInfo:songInfo];
            
            // MEDIA PLAYER
            
            NSLog(@"Artist: %@", self.song);
            NSString* artist = @"";
            if (![self.song[@"artist"] isEqual:[NSNull null]] && [self.song[@"artist"] length] > 0){
                artist = self.song[@"artist"];
            }
            else {
                artist = @"";
            }
            NSNumber* duration = [NSNumber numberWithFloat:[self app].player.duration];
            
            NSDictionary *info = @{ MPMediaItemPropertyArtist: artist,
                                    MPMediaItemPropertyAlbumTitle: @"",
                                    MPMediaItemPropertyTitle: self.song[@"name"],
                                    MPMediaItemPropertyPlaybackDuration: duration,
                                    MPMediaItemPropertyArtwork: albumArt
                                    };
            
            [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = info;
        }
        
    }];
    [task resume];
    
    // PREPARE NEXT SONG
    
    self.playerGui.nowPlayingSongNameLabel.text = self.song[@"name"];
    self.albumCover.image = self.albumCovers[self.nowPlayingTrackIndex];
}

- (void) playNextSong
{
    
    [self.playerGui disableEnableButtons:NO];
    // select next cell
//    NSLog(@"nextTrack: %@", self.tracks[self.nowPlayingTrackIndex+1][@"name"]);
    self.song = self.tracks[self.nowPlayingTrackIndex+1];
    self.nowPlayingTrackIndex += 1;
    NSMutableDictionary* songInfo = [[NSMutableDictionary alloc] init];
    songInfo[@"song"] = self.song[@"name"];
    songInfo[@"album"] = self.albumCovers[self.nowPlayingTrackIndex];
    [self.delegate songChanged:songInfo];
    [self playSong];
}

-(void)playPreviousSong
{
    [self.playerGui disableEnableButtons:NO];
    // select next cell
    self.song = self.tracks[self.nowPlayingTrackIndex-1];
    self.nowPlayingTrackIndex -= 1;
    NSMutableDictionary* songInfo = [[NSMutableDictionary alloc] init];
    songInfo[@"song"] = self.song[@"name"];
    songInfo[@"album"] = self.albumCovers[self.nowPlayingTrackIndex];
    [self.delegate songChanged:songInfo];
    [self playSong];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSMutableDictionary*) getSongInfo
{
    NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
    info[@"song"] = self.song;
    info[@"album"] = self.albumCover.image;
    
    return info;
}

- (void) back
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate keepVC:self];
    }];
}

#pragma mark - wboPlayer Delegate

- (void) playButtonPressed
{
    NSLog(@"Play");
    
    [[self app].player play];
}

-(void) pauseButtonPressed
{
    NSLog(@"Pause");
    [[self app].player pause];
}

-(void) forwardPressed
{
    [self pauseButtonPressed];
    [self.playerGui disableEnableButtons:NO];
    [self playNextSong];
}

-(void) backwardPressed
{
    [self pauseButtonPressed];
    [self.playerGui disableEnableButtons:NO];
    if (self.nowPlayingTrackIndex > 0) {
        if ([self app].player.currentTime > 3) {
            [self playSong];
        }
        else {
            self.nowPlayingTrackIndex -= 1;
            [self playPreviousSong];
        }
    }
}

- (void) navigateInSong:(float)newTime
{
    [[self app].player setCurrentTime:newTime];
    
    // MPMediaPlayer Duration update
    NSMutableDictionary *playInfo = [NSMutableDictionary dictionaryWithDictionary:[MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo];
    NSNumber *position = [NSNumber numberWithFloat:[self app].player.currentTime];
    [playInfo setObject:position forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = playInfo;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    //if it is a remote control event handle it correctly
    if (event.type == UIEventTypeRemoteControl)
    {
        if (event.subtype == UIEventSubtypeRemoteControlPlay)
        {
            [self playButtonPressed];
            [self.playerGui togglePlayButton];
        }
        else if (event.subtype == UIEventSubtypeRemoteControlPause)
        {
            [self pauseButtonPressed];
            [self.playerGui togglePlayButton];
        }
        else if (event.subtype == UIEventSubtypeRemoteControlNextTrack)
        {
            [self pauseButtonPressed];
            [self playNextSong];
            //            if (self.nowPlayingTrackIndex < [self.tracks count]) {
            //                NSIndexPath* nextSongPath = [NSIndexPath indexPathForRow:(self.nowPlayingTrackIndex+1) inSection:0];
            //                [self selectRow:self.tableView didSelectRowAtIndexPath:nextSongPath];
            //            }
        }
        else if (event.subtype == UIEventSubtypeRemoteControlPreviousTrack)
        {
            [self pauseButtonPressed];
            if (self.nowPlayingTrackIndex > 0) {
                [self backwardPressed];
            }
        }
    }
}

#pragma mark - timer

// TIMER

- (void) updateSlider
{
    [self.playerGui.trackProgressSlider setValue: [self app].player.currentTime animated:YES];
}

- (void) startTimer
{
    //enable buttons
    //[self.playerGui disableEnableButtons:YES];
//    if ([self app].player.data) {
//        [self.playerGui disableEnableButtons:YES];
//    }
    self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(countup) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

- (void) clock
{
}

- (void) countup
{
    if ([self app].player.isPlaying == YES) {
        [self.playerGui disableEnableButtons:YES];
    }
    [self.playerGui.trackProgressSlider setValue:[self app].player.currentTime animated:YES];
    [self.playerGui setSongDuration:self.playerGui.trackProgressSlider.value andDuration:[self app].player.duration];
    [self.loading stopAnimating];
    
    if ([self app].player.currentTime > [self app].player.duration-1) {
        [[self app].player prepareToPlay];
        [self.timer invalidate];
        if (self.nowPlayingTrackIndex < self.tracks.count - 1) {
            [self playNextSong];
        }
        else {
            //            UITableViewCell* thisSongCell = [self.tableView cellForRowAtIndexPath:thisSongCellPath];
            //            thisSongCell.contentView.backgroundColor = [UIColor colorWithRed:0x1F/255.0 green:0x32/255.0 blue:0x4D/255.0 alpha:1.0];
        }
        [self.playerGui resetProgress];
    }
}

@end
