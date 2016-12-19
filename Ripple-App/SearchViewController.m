//
//  SearchViewController.m
//  Ripple-App
//
//  Created by William O'Connor on 9/7/15.
//  Copyright (c) 2015 Ripple. All rights reserved.
//

#import "SearchViewController.h"
#import "DataManager.h"
#import "Colors.h"
#import "AppDelegate.h"
#import "LoadingScreen.h"
#import <SCRequest.h>

@interface SearchViewController ()

@property (strong, nonatomic) UITableView* tableView;
@property (strong, nonatomic) NSMutableArray* tracks;
@property (strong, nonatomic) UISearchBar* searchBar;

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
@property (strong, nonatomic) NSDictionary* user;

@property (strong, nonatomic) PlayerViewController* playerView;
@property (strong, nonatomic) NSString* footerText;
@property (strong, nonatomic) UIImage* footerAlbum;
@property (strong, nonatomic) NowPlayingFooter* footer;

@end

@implementation SearchViewController

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
    
    self.user = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    
    self.nowPlayingTrackIndex = -1;
    
    // Do any additional setup after loading the view.
    NSDictionary *screen = [[NSUserDefaults standardUserDefaults] objectForKey:@"screen"];
    UIView* fakeNavBar = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, [screen[@"width"] floatValue], 64.0)];
    fakeNavBar.backgroundColor = cPrimaryPink;
    [self.view addSubview:fakeNavBar];
    //NAV TITLE
//    UIImageView* logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake([self.screenSize[@"width"] floatValue]/2 - 72.5, 12.0, 145.0, 40.0)];
//    logoImageView.image = [UIImage imageNamed:@"logoSmall.png"];
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake([self.screenSize[@"width"] floatValue]/2 - 72.5, 18.0, 145.0, 40.0)];
    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont fontWithName:@"Avenir" size:28.0], NSFontAttributeName,
                                cWhite, NSForegroundColorAttributeName,
                                nil];
    NSMutableAttributedString* navTitle = [[NSMutableAttributedString alloc] initWithString:@"search" attributes:attributes];
    [navTitle addAttribute:NSKernAttributeName
                     value:@(2.0)
                     range:NSMakeRange(0, 5)];
    titleLabel.attributedText = navTitle;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [fakeNavBar addSubview:titleLabel];
    //BACK BUTTON
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    backButton.frame = CGRectMake(12.0, 32.0, 50.0, 21.0);
    [backButton setTintColor:[UIColor whiteColor]];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    backButton.titleLabel.font = [UIFont fontWithName:@"Avenir Next" size:17];
    [fakeNavBar addSubview:backButton];
    
    // SEARCH BAR
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 64.0, [self.screenSize[@"width"] floatValue], 44.0)];
    self.searchBar.delegate = self;
    [self.view addSubview:self.searchBar];
    // SEARCH BUTTON
//    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    searchButton.frame = CGRectMake([self.screenSize[@"width"] floatValue] - 80.0, 64.0, 60.0, 44.0);
//    [searchButton setTintColor:cPrimaryRed];
//    [searchButton setTitle:@"Search" forState:UIControlStateNormal];
//    [searchButton addTarget:self action:@selector(searchButtonPressed) forControlEvents:UIControlEventTouchUpInside];
//    searchButton.titleLabel.font = [UIFont fontWithName:@"Poiret One" size:18];
    //[self.view addSubview:searchButton];
    
    // TABLEVIEW
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.frame = CGRectMake(0.0, 108.0, [self.screenSize[@"width"] doubleValue], [self.screenSize[@"height"] doubleValue] - 108.0);
    self.tableView.backgroundColor = cWhite;
    self.view.backgroundColor = cWhite;
    [self.tableView registerClass:[songCell class] forCellReuseIdentifier:@"cell"];
    self.tableView.rowHeight = 100.0;
    [self.tableView setSeparatorColor:cPrimaryNavy];
    //[self.view addSubview:self.tableView];
    
    // EMPTY CONTENT
    self.emptyContentView = [[UIImageView alloc] initWithFrame:CGRectMake(([screen[@"width"] floatValue]-300)/2, 128, 300, 300)];
    self.emptyContentView.image = [UIImage imageNamed:@"empty-search"];
    [self.view addSubview:self.emptyContentView];
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
        [[self app].footer showUnderView:self.tableView  atY:[self.screenSize[@"height"] floatValue] - [self app].footer.height];
    }
    
    else if ([self app].player.duration > 0) {
        [self app].footer = [[NowPlayingFooter alloc] initWithSongName:self.footerText andAlbumCover:self.footerAlbum];
        [self app].footer.delegate = self;
        [self.view addSubview:[self app].footer];
        [self.view bringSubviewToFront:[self app].footer];
        [[self app].footer showUnderView: self.tableView atY:[self.screenSize[@"height"] floatValue] - [self app].footer.height];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadSongs {
    
    // reset arrays
    [self.tracks removeAllObjects];
    [self.albumCovers removeAllObjects];
    
    NSDictionary* songs = [DataManager getDropsForUser: self.user[@"_id"]];
    
    for (NSDictionary* song in songs) {
        if (song && (BOOL)song[@"streamable"] == true && ![self.songIdsInFeed containsObject: song[@"id"]]) {
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
    
    [self.loading stopAnimating];
    [self.tableView reloadData];
}

- (void) back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) searchButtonPressed
{
    // reset arrays
    [self.tracks removeAllObjects];
    [self.albumCovers removeAllObjects];
    
    NSString* queryString = self.searchBar.text;
    NSDictionary* songs = [DataManager searchSoundcloud:[queryString stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
    
    for (NSDictionary* song in songs) {
        if (song && (BOOL)song[@"streamable"] == true) {
            [self.tracks addObject: [self formatSearchTrack:song]];
            
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
    
    [self.loading stopAnimating];

    if ([self.tracks count] == 0) {
        [self showEmptyContent];
    }
    else {
        [self showTableView];
        [self.tableView reloadData];
    }
}

- (NSDictionary*) formatSearchTrack: (NSDictionary*)track
{
    NSMutableDictionary* newTrack = [NSMutableDictionary dictionaryWithDictionary:track];
    newTrack[@"name"] = track[@"title"];
    if (track[@"label_name"] && ![track[@"label_name"] isEqual:[NSNull null]] ) {
        newTrack[@"artist"] = track[@"label_name"];
    }
    else if ([[track[@"user"] allKeys] count] > 0) {
        newTrack[@"artist"] = track[@"user"][@"username"];
    }
    else {
        newTrack[@"artist"] = @"";
    }
    newTrack[@"soundcloud_track_id"] = track[@"id"];
    newTrack[@"type"] = @"drop";
    
    return newTrack;
}

#pragma mark - Ripple Song Cell Delegate
- (BOOL) drop:(NSString*) type andTrack:(NSDictionary*)track
{
    NSLog(@"%@", [NSString stringWithFormat:@"%@", [self app].footer.playerVC.song]);
    NSLog(@"%@", [NSString stringWithFormat:@"%@", track]);
    NSDictionary* location = [[NSUserDefaults standardUserDefaults] objectForKey:@"location"];
    
    NSIndexPath* path = [NSIndexPath indexPathForRow:self.nowPlayingTrackIndex inSection:0];
    [self deselectRow:self.tableView didDeselectRowAtIndexPath:path];
    
    NSMutableDictionary* drop = [[NSMutableDictionary alloc] init];
    
    if ([type isEqualToString:@"redrop"]) { // should always be redrop here
        
        drop[@"lastDropId"] = track[@"_id"];
        [track[@"previous_dropper_ids"] addObject:self.user[@"_id"]];
        drop[@"previousDropperIds"] = track[@"previous_dropper_ids"];
    }
    
    drop[@"soundcloudTrackId"] = track[@"soundcloud_track_id"];
    drop[@"trackName"] = track[@"name"];
    if ([track[@"artist"] length] > 0) {
        drop[@"artist"] = track[@"artist"];
    }
    else if ([[track[@"user"] allKeys] count] > 0) {
        drop[@"artist"] = track[@"user"][@"username"];
    }
    drop[@"userId"] = self.user[@"_id"];
    drop[@"streamUrl"] = track[@"stream_url"];
    drop[@"artworkUrl"] = track[@"artwork_url"];
    drop[@"streamable"] = track[@"streamable"];
    drop[@"latitude"] = location[@"latitude"];
    drop[@"longitude"] = location[@"longitude"];
    
    NSDictionary* result = [DataManager dropSong:drop];
    [LoadingScreen hideDroppingScreen];
    if (result[@"_id"]){
        NSLog(@"it works");
        [self dropped];
        if (track[@"id"] == [self app].footer.playerVC.song[@"id"]) {
            [self app].footer.playerVC.dropped = YES;
        }
        return YES;
    }
    else {
        UIAlertView* failure = [[UIAlertView alloc] initWithTitle:@"Drop Unsuccessful" message:result[@"reason"] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [failure show];
        return NO;
    }
}

-(void) dropped
{
    if (![UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController.presentedViewController) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self.homeDelegate returnHome];
        }];
    }
    else {
        [self updateDroppedCell];
        [self.homeDelegate returnHome];
    }
}

-(void)updateDroppedCell
{
    
}

#pragma mark - tableview delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    songCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSDictionary *track = [self.tracks objectAtIndex:indexPath.row];
    //    NSLog(@"Track: %@", track);
    [cell setData:track andType:@"drop"];
    cell.albumCover.image = self.albumCovers[indexPath.row];
    [cell createDropButton];
    
    //to change background color of selected cell
    if (indexPath.row == self.nowPlayingTrackIndex) {
        cell.titleLabel.textColor = cPrimaryPink;
        cell.artistLabel.textColor = cPrimaryPink;
    }
    else {
        cell.titleLabel.textColor = cPrimaryNavy;
        cell.artistLabel.textColor = cPrimaryNavy;
    }
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
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
    self.nowPlayingTrackIndex = indexPath.row;
    NSLog(@"index path: %ld", self.nowPlayingTrackIndex);
    
    //    [self playSong:track];
    [self performSegueWithIdentifier:@"searchToPlayerSegue" sender:self];
    
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
    cell.artistLabel.textColor = cPrimaryPink;
}

-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    songCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.titleLabel.textColor = cPrimaryPink;
    cell.artistLabel.textColor = cPrimaryPink;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
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

#pragma mark - navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
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
        dest.dropType = @"drop";
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
    self.playerView = player;
    //[self app].footer.playerVC = player;
    [[self app].footer setPlayerVC:player];
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

#pragma mark - search delegate

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [LoadingScreen showGeneralLoadingScreen];
    [self performSelector:@selector(searchSoundCloud) withObject:nil afterDelay:0.01];
}

-(void)searchSoundCloud
{
    [self.tracks removeAllObjects];
    [self.albumCovers removeAllObjects];
    self.nowPlayingTrackIndex = -1;
    
    NSString* queryString = self.searchBar.text;
    NSDictionary* songs = [DataManager searchSoundcloud:[queryString stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
    
    for (NSDictionary* song in songs) {
        if (song && (BOOL)song[@"streamable"] == true) {
            [self.tracks addObject: [self formatSearchTrack:song]];
            
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
    
    [self.searchBar resignFirstResponder];
    [LoadingScreen hideGeneralLoadingScreen];
    
    if ([self.tracks count] == 0) {
        [self showEmptyContent];
    }
    else {
        [self showTableView];
        [self.tableView reloadData];
    }
}

@end
