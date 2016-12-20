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
#import "LoadingScreen.h"

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
}

-(void)initUI
{
    self.view.backgroundColor = cPrimaryNavy;
    // metrics
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    NSNumber *height = [[NSNumber alloc] initWithDouble:screenHeight];
    NSNumber *width = [[NSNumber alloc] initWithDouble:screenWidth];
    
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
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake([width floatValue]/2 - 72.5, 22.0, 145.0, 40.0)];
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
    self.albumCover.contentMode = UIViewContentModeScaleAspectFit;
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAlbum)];
    doubleTap.numberOfTapsRequired = 2;
    self.albumCover.userInteractionEnabled = YES;
    [self.albumCover addGestureRecognizer:doubleTap];
    [self.view addSubview:self.albumCover];
    
    //GUI
    self.playerGui = [[wboPlayerView alloc] initWithFrame:CGRectMake(0.0, (64 + [width floatValue]), [width floatValue], [height floatValue]-(64 + [width floatValue]))];
    self.playerGui.delegate = self;
    [self.view addSubview:self.playerGui];
}

-(void)initData
{
    self.dropped = NO;
    self.nowPlayingTrackIndex = -1;
}

-(void)updateDelegate
{
    [self.delegate updateTrackIndex:(int)self.nowPlayingTrackIndex];
}

-(void)updatePlayerGui
{
    NSDictionary* song = self.tracks[self.nowPlayingTrackIndex];
    UIImage* albumCover = self.albumCovers[self.nowPlayingTrackIndex];
    
    // PLAYER GUI
    self.playerGui.nowPlayingSongNameLabel.text = song[@"name"];
    self.playerGui.nowPlayingArtistNameLabel.text = song[@"artist"];
    self.playerGui.dropType = song[@"dropType"];
    self.playerGui.track = song;
    
    // ALBUM COVER
    self.albumCover.image = albumCover;
    
    // LOCKED SCREEN INFO
    MPMediaItemArtwork* albumArt = [[MPMediaItemArtwork alloc] initWithImage:albumCover];
    NSString* artist = @"";
    if (![song[@"artist"] isEqual:[NSNull null]] && [song[@"artist"] length] > 0){
        artist = song[@"artist"];
    }
    else {
        artist = @"";
    }
    NSNumber* duration = [NSNumber numberWithFloat:[self app].player.duration];
    NSDictionary *info = @{ MPMediaItemPropertyArtist: artist,
                            MPMediaItemPropertyAlbumTitle: @"",
                            MPMediaItemPropertyTitle: song[@"name"],
                            MPMediaItemPropertyPlaybackDuration: duration,
                            MPMediaItemPropertyArtwork: albumArt
                            };
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = info;
    
}

-(void)updateFooter
{
    NSDictionary* song = self.tracks[self.nowPlayingTrackIndex];
    UIImage* albumCover = self.albumCovers[self.nowPlayingTrackIndex];
    NSDictionary* info = [[NSDictionary alloc] initWithObjectsAndKeys:song[@"name"], @"song", albumCover, @"album", nil];
    if(![self app].footer){
        [self app].footer = [[NowPlayingFooter alloc] initWithSongName:info[@"song"] andAlbumCover:albumCover];
    }
    else {
        [[self app].footer updateInfo:info];
    }
    [self app].footer.playerVC = self;
}

-(void)playSongAtIndex:(int)index inTracks:tracks withAlbumCovers:(NSArray*)albumCovers
{
    [[self app].player stop];
    
    // UPDATE THE DATA
    self.nowPlayingTrackIndex = index;
    self.tracks = [tracks mutableCopy];
    self.albumCovers = [albumCovers mutableCopy];
    
    // PLAY THE SONG
    [self playSong];
    
    // UPDATE DISPLAY
    [self updateFooter];
    [self updateDelegate];
    [self updatePlayerGui];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.dropped == YES && self.playerGui.dropped == NO) {
        [self.playerGui createDropButton];
    }
}

-(void)setDelegate:(id<PlayerDelegate>)delegate
{
    if (self.delegate) {
        [self.delegate updateTrackIndex:-1];
    }
    _delegate = delegate;
}

-(void) playSong
{
    NSDictionary* song = self.tracks[self.nowPlayingTrackIndex];
    
    NSURL *trackURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.soundcloud.com/tracks/%@/stream?client_id=%@", song[@"soundcloud_track_id"], kClientId]];
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

            // set up player session
            [self initPlayerSessionWithData:data];
            
            // play the song
            [[self app].player play];
            [self playerDidStart];
        }
        
    }];
    [task resume];
    
}

-(void)playerDidStart
{
    // TRACK PROGRESS
    NSLog(@"%@", [NSString stringWithFormat:@"%f", [self app].player.duration]);
    self.playerGui.trackProgressSlider.maximumValue = [self app].player.duration;
    self.playerGui.trackProgressSlider.minimumValue = 0;
    
    [self startTimer];
}

-(void)initPlayerSessionWithData:(NSData*)data
{
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
    
    
    //activate the audio session
    success = [session setActive:YES error:&session_error];
    if (!success) NSLog(@"AVAudioSession error activating: %@",session_error);
    else NSLog(@"audioSession active");
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

}

- (void) playNextSong
{
    if (self.nowPlayingTrackIndex + 1 < self.tracks.count) {
        [self playSongAtIndex:(int)self.nowPlayingTrackIndex+1 inTracks:self.tracks withAlbumCovers:self.albumCovers];
    }
    else {
        [self playSongAtIndex:0 inTracks:self.tracks withAlbumCovers:self.albumCovers];
    }
}

-(void)playPreviousSong
{
    [self playSongAtIndex:(int)self.nowPlayingTrackIndex-1 inTracks:self.tracks withAlbumCovers:self.albumCovers];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void) back
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate showFooter];
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
    [self playNextSong];
}

-(void) backwardPressed
{
    [self pauseButtonPressed];
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
    [self.playerGui.trackProgressSlider setValue:[self app].player.currentTime animated:YES];
    [self.playerGui setSongProgress:self.playerGui.trackProgressSlider.value andDuration:[self app].player.duration];

    
    if ([self app].player.duration > 0 && ([self app].player.currentTime > [self app].player.duration-1)) {
        [[self app].player prepareToPlay];
        [self.timer invalidate];
        NSLog(@"%@", [NSString stringWithFormat:@"%f", [self app].player.currentTime]);
        NSLog(@"%@", [NSString stringWithFormat:@"%f", [self app].player.duration-1]);
        [self playNextSong];
        [self.playerGui resetProgress];
    }
}

#pragma mark - drop
- (BOOL) drop:(NSString*)type andTrack:(NSDictionary*)track
{
    BOOL success = [self.delegate drop:type andTrack:track];
    self.dropped = success;
    return success;
}

- (void) doubleTapAlbum
{
    NSDictionary* song = self.tracks[self.nowPlayingTrackIndex];
    
    if (self.dropped == NO) {
        [LoadingScreen showDroppingScreen];
        double delayInSeconds = 0.01;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            BOOL success = [self.delegate drop:song[@"dropType"] andTrack:song];
            self.dropped = success;
            if (success == YES) {
                [self.playerGui setCheckmark];
            }
        });
    }

}

@end
