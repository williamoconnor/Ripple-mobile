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
    
    [self initData];
    [self initUI];
}

-(void) initUI
{
    self.screenSize = [[NSUserDefaults standardUserDefaults] objectForKey:@"screen"];
    NSDictionary *screen = [[NSUserDefaults standardUserDefaults] objectForKey:@"screen"];
    UIView* fakeNavBar = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, [screen[@"width"] floatValue], 64.0)];
    fakeNavBar.backgroundColor = cPrimaryPink;
    [self.view addSubview:fakeNavBar];
    
    //NAV TITLE
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

-(void) initData
{
    self.user = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    
    self.nowPlayingTrackIndex = -1;
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // check for signed in
    
    if ([self app].footer.playerVC.nowPlayingTrackList != 3) {
        self.nowPlayingTrackIndex = -1;
    }
    
    [self.tableView reloadData];
    
    if ([self app].player.duration > 0) {
        [self showFooter];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Ripple Song Cell Delegate
- (BOOL) drop:(NSString*) type andTrack:(NSDictionary*)track
{
    NSDictionary* location = [[NSUserDefaults standardUserDefaults] objectForKey:@"location"];
    
    if(self.nowPlayingTrackIndex >= 0){
        NSIndexPath* path = [NSIndexPath indexPathForRow:self.nowPlayingTrackIndex inSection:0];
        [self deselectRow:self.tableView didDeselectRowAtIndexPath:path];
    }
    
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
        [self dropped:result];
        PlayerViewController* vc = [self app].footer.playerVC;
        if (track[@"id"] == vc.tracks[vc.nowPlayingTrackIndex][@"id"]) {
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

-(void) dropped:(NSDictionary*)drop
{
    if (![UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController.presentedViewController) {
        [self dismissViewControllerAnimated:YES completion:^{ // in search view
            [self.homeDelegate returnHome:drop];
        }];
    }
    else { // in player view
        [self updateDroppedCell];
        [self.homeDelegate returnHome:drop];
    }
}

-(void)updateDroppedCell
{
    if (self.nowPlayingTrackIndex >= 0) {
        NSMutableDictionary* mSong = [self.tracks[self.nowPlayingTrackIndex] mutableCopy];
        mSong[@"dropType"] = @"none";
        self.tracks[self.nowPlayingTrackIndex] = mSong;
        
        [self.tableView reloadData];
    }
}

#pragma mark - tableview delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    songCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *track = [self.tracks objectAtIndex:indexPath.row];
    [cell setData:track andType:track[@"dropType"]];
    cell.albumCover.image = self.albumCovers[indexPath.row];
    if ([track[@"dropType"] isEqualToString: @"drop"]) {
        [cell createDropButton];
    }
    else {
        [cell hideDropButton];
    }
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
    
    cell.delegate = self;
    return cell;
}

// UI UPDATES ARE DONE FROM THE DELEGATE METHODS OF THE PLAYER VIEW, SO THAT ALL UPDATES TO THE UI STATE OF THE APP BASED ON THE PLAYER STATE COME FROM ONE PLACE - THE PLAYERVIEWCONTROLLER

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"searchToPlayerSegue" sender:indexPath];
}

-(void)selectRow:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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

#pragma mark - navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[PlayerViewController class]] && sender != nil) {
        PlayerViewController* dest = segue.destinationViewController;
        dest.delegate = self;
        dest.nowPlayingTrackList = 3;
        [dest initUI];
        [dest initData];
        [dest playSongAtIndex:(int)((NSIndexPath*)(sender)).row inTracks:self.tracks withAlbumCovers:self.albumCovers];
    }
}

#pragma mark - now playing footer delegate
- (void) footerPressed
{
    [self presentViewController:[self app].footer.playerVC animated:YES completion:nil];
}

#pragma mark - player delegate
-(void)updateTrackIndex:(int)index
{
    self.nowPlayingTrackIndex = index;
}

-(void)showFooter
{
    [self app].footer.delegate = self;
    [self.view addSubview:[self app].footer];
    [self.view bringSubviewToFront:[self app].footer];
    [[self app].footer showUnderView: self.tableView atY:[self.screenSize[@"height"] floatValue] - [self app].footer.height];
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
    newTrack[@"dropType"] = @"drop";
    
    return newTrack;
}

@end
