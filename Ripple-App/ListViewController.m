//
//  ViewController.m
//  Ripple-App
//
//  Created by William O'Connor on 4/22/15.
//  Copyright (c) 2015 Ripple. All rights reserved.
//

#import "ListViewController.h"
#import "SCUI.h"
#import "DataManager.h"
#import "PlayerViewController.h"
#import "AppDelegate.h"
#import "NowPlayingFooter.h"
#import "Colors.h"
#import "SearchViewController.h"
#import "LoadingScreen.h"

@interface ListViewController ()

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *tracks;
@property (nonatomic, strong) AVAudioPlayer *player;
@property(nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSDictionary *nowPlayingTrack;
@property (strong, nonatomic) NSMutableDictionary* screenSize;
@property (strong, nonatomic) UIImageView *albumCover;
@property (strong, nonatomic) NSMutableArray *albumCovers;
@property (strong, nonatomic) NSMutableArray *songIds;
@property (strong, nonatomic) wboPlayerView* playerGui;
@property (strong, nonatomic) UIActivityIndicatorView* loading;
@property NSInteger nowPlayingTrackIndex;
//@property (strong, nonatomic) UIBarButtonItem *accountButton;
@property BOOL signedIn;
@property (strong, nonatomic) NSDictionary* user;

@property (strong, nonatomic) PlayerViewController* playerView;
@property (strong, nonatomic) NSString* footerText;
@property (strong, nonatomic) UIImage* footerAlbum;
@property (strong, nonatomic) NowPlayingFooter* footer;

// TIMER
//@property NSTimer *timer;
//@property int time;
//- (void) clock;
//- (void) startTimer;
//- (void) countup;
//- (void) updateSlider;

@end

@implementation ListViewController

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
    // Do any additional setup after loading the view, typically from a nib
    
    [self initUI];
    [self initData];
    
    [self.player prepareToPlay];

}

-(void)initUI
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    NSNumber *height = [[NSNumber alloc] initWithDouble:screenHeight];
    NSNumber *width = [[NSNumber alloc] initWithDouble:screenWidth];
    
    self.screenSize[@"height"] = height;
    self.screenSize[@"width"] = width;
    
    [[NSUserDefaults standardUserDefaults] setObject:self.screenSize forKey:@"screen"];
    
    // TABLEVIEW
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.frame = CGRectMake(0.0, 0.0, [self.screenSize[@"width"] doubleValue], [self.screenSize[@"height"] doubleValue] - 60);
    self.tableView.backgroundColor = cWhite;
    self.tableView.rowHeight = 100.0f;
    [self.tableView setSeparatorColor:cPrimaryNavy];
    self.view.backgroundColor = cWhite;
    [self.tableView registerClass:[songCell class] forCellReuseIdentifier:@"cell"];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    //[self.view addSubview:self.tableView];
    
    // EMPTY CONTENT
    self.emptyContentView = [[UIImageView alloc] initWithFrame:CGRectMake(([width floatValue]-300)/2, 60, 300, 300)];
    self.emptyContentView.image = [UIImage imageNamed:@"empty-feed.png"];
    
    // NAV BAR
    //    UIImage* logoImage = [UIImage imageNamed:@"logoSmall.png"];
    //    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:logoImage];
    self.navigationController.navigationBar.barTintColor = cPrimaryPink;
    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont fontWithName:@"Avenir" size:32.0], NSFontAttributeName,
                                cWhite, NSForegroundColorAttributeName,
                                nil];
    NSMutableAttributedString* navTitle = [[NSMutableAttributedString alloc] initWithString:@"ripple" attributes:attributes];
    [navTitle addAttribute:NSKernAttributeName
                     value:@(4.9)
                     range:NSMakeRange(0, 5)];
    UILabel* navTitleLabel = [[UILabel alloc] init];
    navTitleLabel.attributedText = navTitle;
    [navTitleLabel sizeToFit];
    self.navigationItem.titleView = navTitleLabel;
    self.navigationController.navigationBar.translucent = NO;
    
    // NAV BAR ACCOUNT BUTTON
    UIBarButtonItem *accountButton = [[UIBarButtonItem alloc] initWithTitle:@"Account" style:UIBarButtonItemStylePlain target:self action:@selector(accountButtonPressed)];
    [accountButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                           [UIFont fontWithName:@"Avenir Next" size:17.0], NSFontAttributeName,
                                           cWhite, NSForegroundColorAttributeName,
                                           nil]
                                 forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = accountButton;
    
    // NAV BAR SEARCH BUTTON
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:self action:@selector(searchButtonPressed)];
    [searchButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont fontWithName:@"Avenir Next" size:17.0], NSFontAttributeName,
                                          cWhite, NSForegroundColorAttributeName,
                                          nil]
                                forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = searchButton;
    

}

-(void)initData
{
    self.nowPlayingTrackIndex = -1;
    
    self.user = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    
    // check for location
    [self setUpLocation];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // check for signed in
    [self.tableView reloadData];
    
    if ([self app].player.duration > 0) {
        [self showFooter];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setUpLocation {
    //LOCATION
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLLocationAccuracyThreeKilometers;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager startUpdatingLocation];
    }
    //[self.locationManager stopUpdatingLocation];
}

-(void) locationManager: (CLLocationManager *)manager didUpdateToLocation: (CLLocation *) newLocation
           fromLocation: (CLLocation *) oldLocation {
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
    CLLocation *location = newLocation;
    // Configure the new event with information from the location
    CLLocationCoordinate2D coordinate = [location coordinate];
    
    float longitude = coordinate.longitude;
    float latitude = coordinate.latitude;
    
    NSString *latS = [NSString stringWithFormat:@"%f", latitude];
    NSString *lonS = [NSString stringWithFormat:@"%f", longitude];
    NSDictionary* locationDict = [NSDictionary dictionaryWithObjectsAndKeys:latS, @"latitude", lonS, @"longitude", nil];
    
    [[NSUserDefaults standardUserDefaults] setObject:locationDict forKey:@"location"];
    
    [self loadSongs];
    
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
        {
            UIAlertView* noLocationAlert = [[UIAlertView alloc] initWithTitle:@"Location Tracking Disabled" message:@"Unfortunately, Ripple was not able to detect your location. This is a location-based app, so it will not work without that information. Please try again later." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
            [noLocationAlert show];
        }
            break;
        default:{
            [self.locationManager startUpdatingLocation];
        }
            break;
    }
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"error: %@", error);
    UIAlertView* noLocationAlert = [[UIAlertView alloc] initWithTitle:@"Could not get your location" message:@"Unfortunately, Ripple was not able to detect your location. This is a location-based app, so it will not work without that information. Please try again later." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    [noLocationAlert show];
    
    [self.locationManager stopUpdatingLocation];
    
    [self loadSongs];
}

- (void) loadSongs {
    [LoadingScreen showGeneralLoadingScreen];
    [self performSelector:@selector(retrieveSongs) withObject:nil afterDelay:0.01];
}

-(void)retrieveSongs
{
    NSMutableDictionary *location = [[[NSUserDefaults standardUserDefaults] objectForKey:@"location"] mutableCopy];
        
    // reset arrays
    [self.tracks removeAllObjects];
    [self.albumCovers removeAllObjects];
    
    NSDictionary* songs = [DataManager getDrops:location];
    
    for (NSDictionary* song in songs) {
        if (song && (BOOL)song[@"streamable"] == true) {
            NSMutableDictionary* mutSong = [song mutableCopy];
            if (![song[@"previous_dropper_ids"] containsObject:self.user[@"_id"]]) {
                mutSong[@"dropType"] = @"redrop";
            }
            else {
                mutSong[@"dropType"] = @"none";
            }
            
            [self.tracks addObject: mutSong];
            [self.songIds addObject: song[@"soundcloud_track_id"]];
            
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
    
    if ([self.tracks count] == 0) {
        [self showEmptyContent];
        [LoadingScreen hideGeneralLoadingScreen];
    }
    else {
        [self showTableView];
        [self.tableView reloadData];
        [LoadingScreen hideGeneralLoadingScreen];
    }
}


//     TABLEVIEW

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tracks count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    songCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *track = [self.tracks objectAtIndex:indexPath.row];
    [cell setData:track andType:track[@"dropType"]];
    cell.albumCover.image = self.albumCovers[indexPath.row];
    if ([track[@"dropType"] isEqualToString: @"redrop"]) {
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"playerSegue" sender:indexPath];
}

-(void)selectRow:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
    cell.contentView.backgroundColor = cWhite;
    cell.titleLabel.textColor = cPrimaryNavy;
    cell.artistLabel.textColor = cPrimaryNavy;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    //MAINTAIN PROPER HIGHLIGHTING
    NSInteger oldNumSongs = [self.tracks count];
    [self loadSongs];
    NSInteger offset = 0;
    if (self.nowPlayingTrackIndex > -1) { // a song is playing
        offset = [self.tracks count] - oldNumSongs;
    }
    self.nowPlayingTrackIndex += offset;
    
    // ^ That only works when I don't get a full array back
    if (self.nowPlayingTrackIndex >= 0) {
        NSIndexPath* path = [NSIndexPath indexPathForRow:self.nowPlayingTrackIndex inSection:0];
        [self deselectRow:self.tableView didDeselectRowAtIndexPath:path];
    }
    [self.tableView reloadData];
    
    // CELL COLORS
    // paths
    NSIndexPath *oldCellPath = [NSIndexPath indexPathForRow:oldNumSongs inSection:0];
    NSIndexPath *newCellPath = [NSIndexPath indexPathForRow:[self.tracks count] inSection:0];
    // cells
    UITableViewCell *oldCell = [self.tableView cellForRowAtIndexPath:oldCellPath];
    UITableViewCell *newCell = [self.tableView cellForRowAtIndexPath:newCellPath];
    //colors
    newCell.contentView.backgroundColor = cSlateNavy;
    oldCell.contentView.backgroundColor = cDarkGray;
    
    [refreshControl endRefreshing];
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

- (void) accountButtonPressed {
    [self performSegueWithIdentifier:@"accountSegue" sender:self];
}

- (void) searchButtonPressed {
    [self performSegueWithIdentifier:@"searchSegue" sender:self];
}

#pragma mark - Ripple Song Cell Delegate
- (BOOL) drop:(NSString*) type andTrack:(NSDictionary*)track
{
    NSDictionary* location = [[NSUserDefaults standardUserDefaults] objectForKey:@"location"];
    
    if (self.nowPlayingTrackIndex >= 0) {
        NSIndexPath* path = [NSIndexPath indexPathForRow:self.nowPlayingTrackIndex inSection:0];
        [self deselectRow:self.tableView didDeselectRowAtIndexPath:path];
    }
    
    NSMutableDictionary* drop = [[NSMutableDictionary alloc] init];
    
    /*if ([type isEqualToString:@"redrop"]) { // should always be redrop here
        
        drop[@"lastDropId"] = track[@"_id"];
        NSMutableArray* pdi = [track[@"previous_dropper_ids"] mutableCopy];
        [pdi addObject:self.user[@"_id"]];
        drop[@"previousDropperIds"] = pdi;
    }*/
    
    drop[@"soundcloudTrackId"] = track[@"soundcloud_track_id"];
    drop[@"trackName"] = track[@"name"];
    drop[@"artist"] = track[@"artist"];
    drop[@"userId"] = self.user[@"_id"];
    drop[@"streamUrl"] = track[@"stream_url"];
    drop[@"artworkUrl"] = track[@"artwork_url"];
    drop[@"streamable"] = track[@"streamable"];
    drop[@"latitude"] = location[@"latitude"];
    drop[@"longitude"] = location[@"longitude"];
    
    NSDictionary* result = [DataManager dropSong:drop];
    [LoadingScreen hideDroppingScreen];
    if (result[@"drop"][@"_id"]){
//        [self.loading startAnimating];
        [self loadSongs];
        [self.tableView reloadData];
        
        PlayerViewController* vc = [self app].footer.playerVC;
        if (track[@"soundcloud_track_id"] == vc.tracks[vc.nowPlayingTrackIndex][@"soundcloud_track_id"]) {
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

#pragma mark - navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[PlayerViewController class]] && sender != nil) {
        PlayerViewController* dest = segue.destinationViewController;
        dest.delegate = self;
        [dest initUI];
        [dest initData];
        [dest playSongAtIndex:(int)((NSIndexPath*)(sender)).row inTracks:self.tracks withAlbumCovers:self.albumCovers];
    }
    
    else if ([segue.destinationViewController isKindOfClass:[SearchViewController class]]) {
        SearchViewController* dest = segue.destinationViewController;
        dest.homeDelegate = self;
        dest.songIdsInFeed = self.songIds;
    }
}

#pragma mark - now playing footer delegate
- (void) footerPressed
{
    PlayerViewController* vc = [self app].footer.playerVC;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - player delegate

-(void)showFooter
{
    [self app].footer.delegate = self;
    [self.view addSubview:[self app].footer];
    [self.view bringSubviewToFront:[self app].footer];
    [self.tableView setFrame:CGRectMake(0.0, 0.0, [self.screenSize[@"width"] doubleValue], [self.screenSize[@"height"] doubleValue] - 60)];
    [[self app].footer showUnderView:self.tableView atY:0.0];
}

-(void)deselectLastSongCell
{
    if(self.nowPlayingTrackIndex >= 0) {
        NSIndexPath *lastSongCellPath = [NSIndexPath indexPathForRow:self.nowPlayingTrackIndex inSection:0];
        [self deselectRow:self.tableView didDeselectRowAtIndexPath:lastSongCellPath];
    }
}

-(void)selectCurrentSongCell
{
    if (self.nowPlayingTrackIndex >= 0) {
        NSIndexPath *thisSongCellPath = [NSIndexPath indexPathForRow:(self.nowPlayingTrackIndex) inSection:0];
        [self selectRow:self.tableView didSelectRowAtIndexPath:thisSongCellPath];
    }
}

-(void)updateTrackIndex:(int)index
{
    [self deselectLastSongCell];
    self.nowPlayingTrackIndex = index;
    [self selectCurrentSongCell];
}

#pragma mark - searchProtocol

-(void) returnHome
{
    [self loadSongs];
}

@end
