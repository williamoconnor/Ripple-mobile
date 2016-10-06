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
    
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user"];
    
    self.nowPlayingTrackIndex = -1;
    
    self.user = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    NSNumber *height = [[NSNumber alloc] initWithDouble:screenHeight];
    NSNumber *width = [[NSNumber alloc] initWithDouble:screenWidth];
    
    self.screenSize[@"height"] = height;
    self.screenSize[@"width"] = width;
    
    [[NSUserDefaults standardUserDefaults] setObject:self.screenSize forKey:@"screen"];

//      PLAYER
//    self.playerGui = [[wboPlayerView alloc] initWithFrame:CGRectMake(0.0, 184.0, [self.screenSize[@"width"] doubleValue], 80.0)];
//    self.playerGui.hidden = YES;
//    self.playerGui.delegate = self;
//    [self.view addSubview:self.playerGui];
//
    
    // TABLEVIEW
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.frame = CGRectMake(0.0, 0.0, [self.screenSize[@"width"] doubleValue], [self.screenSize[@"height"] doubleValue]);
    self.tableView.backgroundColor = cSlateNavy;
    self.view.backgroundColor = cDarkGray;
    [self.tableView registerClass:[songCell class] forCellReuseIdentifier:@"cell"];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    [self.view addSubview:self.tableView];
    
    //      ACTIVITY INDICATOR
    self.loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    double x = [self.screenSize[@"width"] doubleValue]/2;
    self.loading.center = CGPointMake(x, 160.0);
    self.loading.hidesWhenStopped = YES;
    [self.tableView addSubview:self.loading];
    [self.tableView bringSubviewToFront:self.loading];
    
    [self.loading startAnimating];
    
    // NAV BAR
//    UIImage* logoImage = [UIImage imageNamed:@"logoSmall.png"];
//    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:logoImage];
    self.navigationController.navigationBar.barTintColor = cSlateNavyNav;
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                   [UIFont fontWithName:@"Poiret One" size:24.0], NSFontAttributeName,
                                                                   cWhite, NSForegroundColorAttributeName,
                                                                   nil];
    self.navigationItem.title = @"Feed";
    
    // NAV BAR ACCOUNT BUTTON
    UIBarButtonItem *accountButton = [[UIBarButtonItem alloc] initWithTitle:@"Account" style:UIBarButtonItemStylePlain target:self action:@selector(accountButtonPressed)];
    [accountButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont fontWithName:@"Poiret One" size:18.0], NSFontAttributeName,
                                        cWhite, NSForegroundColorAttributeName,
                                        nil] 
                              forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = accountButton;
    
    // NAV BAR SEARCH BUTTON
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:self action:@selector(searchButtonPressed)];
    [searchButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                           [UIFont fontWithName:@"Poiret One" size:18.0], NSFontAttributeName,
                                           cWhite, NSForegroundColorAttributeName,
                                           nil]
                                 forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = searchButton;
    
    
    
    // check for location
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"latitude"]) {
        [self setUpLocation];
    }
    else {
        NSLog(@"Location already set");
        [self loadSongs];
    }
    
    [self.player prepareToPlay];
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // check for signed in
    [self.tableView reloadData];
    
//    if ([self app].footer) {
//        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, [self.screenSize[@"height"] floatValue]-60.0);
//        [self app].footer.delegate = self;
//        [self.view addSubview:[self app].footer];
//        [self.view bringSubviewToFront:[self app].footer];
//    }
    
    if ([self app].player.data) {
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, [self.screenSize[@"height"] floatValue] - (64 + 60));
        [self app].footer = [[NowPlayingFooter alloc] initWithSongName:self.footerText andAlbumCover:self.footerAlbum];
        [self app].footer.delegate = self;
        [self.view addSubview:[self app].footer];
        [self.view bringSubviewToFront:[self app].footer];
        
        NSLog(@"%@",self.navigationController.viewControllers);
    }
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
    CLLocation *location = newLocation;
    // Configure the new event with information from the location
    CLLocationCoordinate2D coordinate = [location coordinate];
    
    float longitude = coordinate.longitude;
    float latitude = coordinate.latitude;
    
    int lat = (int) latitude;
    int lon = (int) longitude;
    
    NSString *latS = [NSString stringWithFormat:@"%i", lat];
    NSString *lonS = [NSString stringWithFormat:@"%i", lon];
    
    [[NSUserDefaults standardUserDefaults] setObject:latS forKey:@"latitude"];
    [[NSUserDefaults standardUserDefaults] setObject:lonS forKey:@"longitude"];
    [self.locationManager stopUpdatingLocation];
    
    [self loadSongs];
    
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
        {
            // do some error handling
        }
            break;
        default:{
            [self.locationManager startUpdatingLocation];
        }
            break;
    }
}

- (void) loadSongs {
    NSMutableDictionary *location = [[NSMutableDictionary alloc] init];
    location[@"latitude"] = [[NSUserDefaults standardUserDefaults] objectForKey:@"latitude"];
    location[@"longitude"] = [[NSUserDefaults standardUserDefaults] objectForKey:@"longitude"];
    
    // reset arrays
    [self.tracks removeAllObjects];
    [self.albumCovers removeAllObjects];
    
    // HARDCODE LOCATION
    NSNumber *tempNumber = [[NSNumber alloc] initWithDouble:32.846];
    location[@"latitude"] = location[@"latitude"];
    NSNumber *tempNumber2 = [[NSNumber alloc] initWithDouble:-96.7837];
    location[@"longitude"] = location[@"longitude"];
    [[NSUserDefaults standardUserDefaults] setObject:location forKey:@"location"];
    
    NSDictionary* songs = [DataManager getDrops:location];
    NSLog(@"Got the song IDs");
    
    for (NSDictionary* song in songs) {
        if (song && (BOOL)song[@"streamable"] == true) {
            [self.tracks addObject: song];
            [self.songIds addObject: song[@"soundcloud_track_id"]];
    
            // YOOO
            UIImage* albumCoverImage = [UIImage imageNamed:@"NowPlaying.png"];
            if (![song[@"artwork_url"] isEqual:[NSNull null]] && [song[@"artwork_url"] length] > 0){
                NSString* url = [song[@"artwork_url"] stringByReplacingOccurrencesOfString:@"large"                                                        withString:@"crop"];
                albumCoverImage = [UIImage imageWithData:
                                            [NSData dataWithContentsOfURL:
                                             [NSURL URLWithString: url]]];
            }
            
            [self.albumCovers addObject:albumCoverImage];
        }
    }
    NSLog(@"Got the actual songs");
    
    [self.loading stopAnimating];
    [self.tableView reloadData];
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"error: %@", error);
    UIAlertView* noLocationAlert = [[UIAlertView alloc] initWithTitle:@"Could not get your location" message:@"Unfortunately, Ripple was not able to detect your location. This is a location-based app, so it will not work without that information. Please try again later." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    [noLocationAlert show];
    
    [self.locationManager stopUpdatingLocation];
    
    [self loadSongs];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    NSDictionary *track = [self.tracks objectAtIndex:indexPath.row];
//    NSLog(@"Track: %@", track);
    [cell setData:track andType:@"redrop"];
    
    //to change background color of selected cell
    if (indexPath.row == self.nowPlayingTrackIndex) {
        cell.contentView.backgroundColor = cDarkGray;
    }
    else {
        cell.contentView.backgroundColor = cSlateNavy;
    }
    
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
    
//    if (self.tableView.frame.origin.y == 264.0) {
//        self.albumCover.hidden = NO;
//        self.playerGui.hidden = NO;
//        self.playerGui.playButton.hidden = YES;
//        self.playerGui.pauseButton.hidden = NO;
//    }
//    else {
//        NSLog(@"%f", self.tableView.frame.origin.y);
//    }
    
    
    // PLAY SONG
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor = cDarkGray;
    self.nowPlayingTrackIndex = indexPath.row;
    NSLog(@"index path: %ld", self.nowPlayingTrackIndex);
    
//    [self playSong:track];
    [self performSegueWithIdentifier:@"playerSegue" sender:self];
    
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
    cell.contentView.backgroundColor = cDarkGray;
}


-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor = cDarkGray;
}

-(void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor = cSlateNavy;
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
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor = cSlateNavy;
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
    
    NSIndexPath* path = [NSIndexPath indexPathForRow:self.nowPlayingTrackIndex inSection:0];
    [self deselectRow:self.tableView didDeselectRowAtIndexPath:path];
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

- (void) accountButtonPressed {
    [self performSegueWithIdentifier:@"accountSegue" sender:self];
}

- (void) searchButtonPressed {
    [self performSegueWithIdentifier:@"searchSegue" sender:self];
}

#pragma mark - Ripple Song Cell Delegate
- (void) drop:(NSString*) type andTrack:(NSDictionary*)track
{
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
    drop[@"artist"] = track[@"artist"];
    drop[@"userId"] = self.user[@"_id"];
    drop[@"streamUrl"] = track[@"stream_url"];
    drop[@"artworkUrl"] = track[@"artwork_url"];
    drop[@"streamable"] = track[@"streamable"];
    drop[@"latitude"] = location[@"latitude"];
    drop[@"longitude"] = location[@"longitude"];
    
    NSDictionary* result = [DataManager dropSong:drop];
    if (result[@"_id"]){
        [self.loading startAnimating];
        [self loadSongs];
        [self.tableView reloadData];
        
        // FIGURE THIS OUT
        
        [self.loading stopAnimating];
        NSLog(@"it works");
    }
    else {
        UIAlertView* failure = [[UIAlertView alloc] initWithTitle:@"Drop Unsuccessful" message:result[@"reason"] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [failure show];
    }
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
        
        dest.song = self.tracks[(long)self.nowPlayingTrackIndex];
        [dest.tracks removeAllObjects];
        dest.tracks = self.tracks;
        dest.nowPlayingTrackIndex = self.nowPlayingTrackIndex;
        dest.albumCovers = self.albumCovers;
        dest.delegate = self;
        [dest playSong];
        
        // BACK BUTTON
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Songs" style:UIBarButtonItemStylePlain target:nil action:nil];
        
        NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                       [UIFont fontWithName:@"Poiret One" size:18.0], NSFontAttributeName,
                       cWhite, NSForegroundColorAttributeName,
                                    nil];
        [[UIBarButtonItem appearance] setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          cWhite, NSForegroundColorAttributeName,
          [UIFont fontWithName:@"Poiret One" size:18.0], NSFontAttributeName,
          nil] forState:UIControlStateNormal];
        self.navigationController.navigationBar.tintColor = cWhite;
//        [self.navigationItem.backBarButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
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

#pragma mark - searchProtocol

-(void) returnHome
{
    [self loadSongs];
}

@end
