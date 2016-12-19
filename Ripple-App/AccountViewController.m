//
//  AccountViewController.m
//  Ripple-App
//
//  Created by William O'Connor on 5/1/15.
//  Copyright (c) 2015 Ripple. All rights reserved.
//

#import "AccountViewController.h"
#import "DataManager.h"
#import "Colors.h"
#import "AppDelegate.h"
#import "SignInViewController.h"
#import "Rankings.h"
#import "LoadingScreen.h"

@interface AccountViewController ()

@property (strong, nonatomic) NSDictionary* userAccount;
@property (strong, nonatomic) UITableView* tableView;
@property (strong, nonatomic) NSMutableArray* tracks;

@property (nonatomic, strong) AVAudioPlayer *player;
@property(nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSDictionary *nowPlayingTrack;
@property (strong, nonatomic) NSMutableDictionary* screenSize;
@property (strong, nonatomic) UIImageView *albumCover;
@property (strong, nonatomic) NSMutableArray *albumCovers;
@property (strong, nonatomic) wboPlayerView* playerGui;
@property (strong, nonatomic) UIActivityIndicatorView* loading;
@property NSInteger nowPlayingTrackIndex;
@property BOOL signedIn;

@property (strong, nonatomic) PlayerViewController* playerView;
@property (strong, nonatomic) NSString* footerText;
@property (strong, nonatomic) UIImage* footerAlbum;
@property (strong, nonatomic) NowPlayingFooter* footer;

@end

@implementation AccountViewController

-(AppDelegate*) app
{
    return (AppDelegate*) [[UIApplication sharedApplication] delegate];
}

-(NSMutableArray*)tracks
{
    if (!_tracks) {
        _tracks = [[NSMutableArray alloc] init];
    }
    return _tracks;
}

-(NSMutableArray*)albumCovers
{
    if (!_albumCovers) {
        _albumCovers = [[NSMutableArray alloc] init];
    }
    return _albumCovers;
}

-(NSMutableDictionary*)screenSize
{
    if (!_screenSize) {
        _screenSize = [[NSMutableDictionary alloc] init];
    }
    return _screenSize;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.screenSize = [[NSUserDefaults standardUserDefaults] objectForKey:@"screen"];
    
    self.userAccount = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    
    self.nowPlayingTrackIndex = -1;
    
    // Do any additional setup after loading the view.
    NSDictionary *screen = [[NSUserDefaults standardUserDefaults] objectForKey:@"screen"];
    
    // STATUS HEADER
    self.statusHeader = [[accountStatusHeader alloc] initWithWidth:[screen[@"width"] floatValue] andRank:[self.userAccount[@"rank"] intValue] andPoints:[self.userAccount[@"points"] floatValue]];
    self.statusHeader.delegate = self;
    self.statusHeader.email = self.userAccount[@"email"];
    [self.view addSubview:self.statusHeader];
    
    // EMPTY CONTENT
    float empytSpace = [screen[@"height"] floatValue] - (self.statusHeader.frame.origin.y + self.statusHeader.frame.size.height);
    float empytSpaceY = (self.statusHeader.frame.origin.y + self.statusHeader.frame.size.height);
    self.emptyContentView = [[UIImageView alloc] initWithFrame:CGRectMake(([screen[@"width"] floatValue]-300)/2, empytSpaceY+(empytSpace-300)/2, 300, 300)];
    self.emptyContentView.image = [UIImage imageNamed:@"empty-account.png"];
    
    // TABLEVIEW
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.frame = CGRectMake(0.0, (self.statusHeader.frame.origin.y + self.statusHeader.frame.size.height), [self.screenSize[@"width"] doubleValue], [self.screenSize[@"height"] doubleValue] - (self.statusHeader.frame.origin.y + self.statusHeader.frame.size.height));
    self.tableView.backgroundColor = cWhite;
    self.view.backgroundColor = cWhite;
    [self.tableView registerClass:[songCell class] forCellReuseIdentifier:@"cell"];
    self.tableView.rowHeight = 100.0;
    [self.tableView setSeparatorColor:[Rankings getRankingToUIColor:[self.userAccount[@"rank"] intValue]]];
    
    [self loadSongs];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // check for signed in
    [self.tableView reloadData];
    
    if ([self app].footer) {
        [self app].footer.delegate = self;
        [self.view addSubview:[self app].footer];
        [self.view bringSubviewToFront:[self app].footer];
        [[self app].footer showUnderView:self.tableView atY:[self.screenSize[@"height"] doubleValue] - 60];
    }
    
    else if ([self app].player.duration > 0) { // implied no footer
        [self app].footer = [[NowPlayingFooter alloc] initWithSongName:self.footerText andAlbumCover:self.footerAlbum];
        [self app].footer.delegate = self;
        [self.view addSubview:[self app].footer];
        [self.view bringSubviewToFront:[self app].footer];
        [[self app].footer showUnderView: self.tableView atY:[self.screenSize[@"height"] doubleValue] - 60];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadSongs {
    [LoadingScreen showGeneralLoadingScreen];
    [self performSelector:@selector(retrieveSongs) withObject:nil afterDelay:0.01];
}

-(void)retrieveSongs
{
    // reset arrays
    [self.tracks removeAllObjects];
    [self.albumCovers removeAllObjects];
    
    NSDictionary* songs = [DataManager getDropsForUser: self.userAccount[@"_id"]];
    
    for (NSDictionary* song in songs) {
        if (song && (BOOL)song[@"streamable"] == true) {
            [self.tracks addObject: song];
            
            // YOOO
            UIImage* albumCoverImage = [UIImage imageNamed:@"no-album-cover.png"];
            if (![song[@"artwork_url"] isEqual:[NSNull null]] && [song[@"artwork_url"] length] > 0){
                NSString* url = [song[@"artwork_url"] stringByReplacingOccurrencesOfString:@"large"                                                        withString:@"crop"];
                albumCoverImage = [UIImage imageWithData:
                                   [NSData dataWithContentsOfURL:
                                    [NSURL URLWithString: url]]];
            }
            
            [self.albumCovers addObject:albumCoverImage];
        }
    }
    
    [LoadingScreen hideGeneralLoadingScreen];
    
    if ([self.tracks count] == 0) {
        [self showEmptyContent];
    }
    else {
        [self showTableView];
        [self.tableView reloadData];
    }
}

- (void) back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) logout
{
    [[self app].player stop];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    
    SignInViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"loginScreen"];
    
    [self presentViewController:viewController animated:YES completion:^{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user"];
        [viewController playerStartPlaying];
    }];

    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.destinationViewController isKindOfClass:[PlayerViewController class]] && sender != nil) {
        PlayerViewController* dest = segue.destinationViewController;
        BOOL newsong = true;
        if (dest.song == self.tracks[(long)self.nowPlayingTrackIndex]) {
            newsong = false;
        }
        
        [dest.tracks removeAllObjects];
        dest.song = self.tracks[(long)self.nowPlayingTrackIndex];
        dest.tracks = self.tracks;
        dest.nowPlayingTrackIndex = self.nowPlayingTrackIndex;
        dest.albumCovers = self.albumCovers;
        dest.delegate = self;
        [dest playSong];
        
        // BACK BUTTON
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Songs" style:UIBarButtonItemStylePlain target:nil action:nil];
        
        NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIFont fontWithName:@"Avenir Next" size:17.0], NSFontAttributeName,
                                    cWhite, NSForegroundColorAttributeName,
                                    nil];
        [[UIBarButtonItem appearance] setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          cWhite, NSForegroundColorAttributeName,
          [UIFont fontWithName:@"Avenir Next" size:17.0], NSFontAttributeName,
          nil] forState:UIControlStateNormal];
        self.navigationController.navigationBar.tintColor = cWhite;
        //        [self.navigationItem.backBarButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    }
}


#pragma mark - tableview delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    songCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *track = [self.tracks objectAtIndex:indexPath.row];
    [cell setData:track andType:@"none"];
    cell.albumCover.image = self.albumCovers[indexPath.row];

    cell.contentView.backgroundColor = cWhite;
    
    //to change background color of selected cell
    if (indexPath.row == self.nowPlayingTrackIndex) {
        cell.titleLabel.textColor = cPrimaryPink;
        cell.artistLabel.textColor = cPrimaryPink;
    }
    else {
        cell.titleLabel.textColor = cPrimaryNavy;
        cell.titleLabel.textColor = cPrimaryNavy;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.nowPlayingTrackIndex >= 0) {
        NSIndexPath* lastSong = [NSIndexPath indexPathForRow:self.nowPlayingTrackIndex inSection:0];
        [self deselectRow:self.tableView didDeselectRowAtIndexPath:lastSong];
    }
    NSDictionary *track = [self.tracks objectAtIndex:indexPath.row];
    NSLog(@"track: %@", track[@"name"]);
    //    [self.timer invalidate];
    
    //loader
    double x = [self.screenSize[@"width"] doubleValue]/2;
    self.loading.center = CGPointMake(x, 100.0);
    [self.albumCover addSubview:self.loading];
    [self.albumCover bringSubviewToFront:self.loading];
    [self.loading startAnimating];
    
    // PLAY SONG
    songCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.titleLabel.textColor = cPrimaryPink;
    cell.artistLabel.textColor = cPrimaryPink;
    self.nowPlayingTrackIndex = indexPath.row;
    NSLog(@"index path: %ld", self.nowPlayingTrackIndex);
    
    //    [self playSong:track];
    [self performSegueWithIdentifier:@"accountToPlayerSegue" sender:self];
    
    if ([[self app].player isPlaying]) {
        [[self app].player stop];
    }
}

-(void)selectRow:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.nowPlayingTrack = [self.tracks objectAtIndex:indexPath.row];
    //    [self.timer invalidate];
    
    //loader
    double x = [self.screenSize[@"width"] doubleValue]/2;
    self.loading.center = CGPointMake(x, 100.0);
    [self.loading startAnimating];
    
    // PLAY SONG
    songCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.titleLabel.textColor = cPrimaryPink;
    cell.artistLabel.textColor = cPrimaryPink;}

-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    songCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.titleLabel.textColor = cPrimaryPink;
    cell.artistLabel.textColor = cPrimaryPink;
}

-(void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    songCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.titleLabel.textColor = cPrimaryNavy;
    cell.artistLabel.textColor = cPrimaryNavy;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // STYLE
    songCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
}

-(void)deselectRow:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // STYLE
    songCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.titleLabel.textColor = cPrimaryNavy;
    cell.artistLabel.textColor = cPrimaryNavy;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tracks count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)showTableView
{
    if (self.emptyContentView) {
        [self.emptyContentView removeFromSuperview];
        [self.view addSubview:self.tableView];
        self.emptyContentView = nil;
    }
}

-(void)showEmptyContent
{
    [self.view addSubview:self.emptyContentView];
}

// DELEGATE METHODS

- (void) playButtonPressed
{
    NSLog(@"Play");
    
    [self.player play];
}

-(void) pauseButtonPressed
{
    NSLog(@"Pause");
    [self.player pause];
}

- (void) navigateInSong:(float)newTime
{
    [self.player setCurrentTime:newTime];
    
    // MPMediaPlayer Duration update
    NSMutableDictionary *playInfo = [NSMutableDictionary dictionaryWithDictionary:[MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo];
    NSNumber *position = [NSNumber numberWithFloat:self.player.currentTime];
    [playInfo setObject:position forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = playInfo;
}

#pragma mark - now playing footer delegate
- (void) footerPressed
{
    [self presentViewController:[self app].footer.playerVC animated:YES completion:nil];
}

#pragma mark - player delegate
-(void) setSongInfo:(NSDictionary *)info
{
    self.footerAlbum = info[@"album"];
    self.footerText = info[@"song"];
    [[self app].footer updateInfo:info];
}

-(void) keepVC:(id)player
{
    // self.playerView = player;
    [self app].footer.playerVC = player;
}

-(void)songChanged:(NSDictionary *)info
{
    [self setSongInfo:info];
    NSIndexPath *lastSongCellPath = [NSIndexPath indexPathForRow:self.nowPlayingTrackIndex inSection:0];
    [self deselectRow:self.tableView didDeselectRowAtIndexPath:lastSongCellPath];
    
    NSIndexPath *thisSongCellPath = [NSIndexPath indexPathForRow:(self.nowPlayingTrackIndex+1) inSection:0];
    [self selectRow:self.tableView didSelectRowAtIndexPath:thisSongCellPath];
    
    self.nowPlayingTrackIndex += 1;
}


@end
