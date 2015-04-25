//
//  ViewController.m
//  Ripple-App
//
//  Created by William O'Connor on 4/22/15.
//  Copyright (c) 2015 Gooey Dee Bee. All rights reserved.
//

#import "ViewController.h"
#import "SCUI.h"
#import "DataManager.h"
#import "songCell.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *tracks;
@property (nonatomic, strong) AVAudioPlayer *player;
@property(nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSDictionary *nowPlayingTrack;
@property (strong, nonatomic) NSMutableDictionary* screenSize;
@property (strong, nonatomic) UIImageView *albumCover;
@property (strong, nonatomic) NSMutableArray *albumCovers;

@end

@implementation ViewController

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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    NSNumber *height = [[NSNumber alloc] initWithDouble:screenHeight];
    NSNumber *width = [[NSNumber alloc] initWithDouble:screenWidth];
    
    self.screenSize[@"height"] = height;
    self.screenSize[@"width"] = width;
    
    self.albumCover = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 64.0, 400.0, 200.0)];
    self.albumCover.hidden = YES;
    [self.view addSubview:self.albumCover];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor colorWithRed:0x1F/255.0 green:0x32/255.0 blue:0x4D/255.0 alpha:1.0];
    self.view.backgroundColor = [UIColor colorWithRed:0x1F/255.0 green:0x32/255.0 blue:0x4D/255.0 alpha:1.0];
    [self.tableView registerClass:[songCell class] forCellReuseIdentifier:@"cell"];
    self.navigationItem.title = @"Ripple";
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor whiteColor], NSForegroundColorAttributeName,
      [UIFont fontWithName:@"Cookie" size:44],
       NSFontAttributeName, nil]];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0x48/255.0 green:0x98/255.0 blue:0xBD/255.0 alpha:1.0];
    [self setUpLocation];
}

- (void) setUpLocation {
    //LOCATION
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLLocationAccuracyThreeKilometers;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        NSLog(@"Hey bitch");
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager startUpdatingLocation];
    }
//    [self.locationManager stopUpdatingLocation];
}

-(void) locationManager: (CLLocationManager *)manager didUpdateToLocation: (CLLocation *) newLocation
           fromLocation: (CLLocation *) oldLocation {
    NSLog(@"HERE");
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
    NSLog(@"What the fukc");
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
//    location[@"latitude"] = [[NSUserDefaults standardUserDefaults] objectForKey:@"latitude"];
//    location[@"longitude"] = [[NSUserDefaults standardUserDefaults] objectForKey:@"longitude"];
    
    // HARDCODE LOCATION
    NSNumber *tempNumber = [[NSNumber alloc] initWithDouble:32.846];
    location[@"latitude"] = tempNumber;
    NSNumber *tempNumber2 = [[NSNumber alloc] initWithDouble:-96.7837];
    location[@"longitude"] = tempNumber2;
    
    NSDictionary* songs = [DataManager getSongList:location];
//    NSLog(@"Songs: %@", songs);
    
    for (NSDictionary* song_id in songs) {
//        NSLog(@"song id: %@", song_id[@"song_id"]);
        NSDictionary* track = [DataManager getTrackInfo:song_id[@"song_id"]];
        
        [self.tracks addObject: track];
        
        
        // YOOO
        UIImage* albumCoverImage = [UIImage imageNamed:@"NowPlaying.png"];
        if (![track[@"artwork_url"] isEqual:[NSNull null]] && [track[@"artwork_url"] length] > 0){
            NSString* url = [track[@"artwork_url"] stringByReplacingOccurrencesOfString:@"large"                                                        withString:@"crop"];
            albumCoverImage = [UIImage imageWithData:
                                        [NSData dataWithContentsOfURL:
                                         [NSURL URLWithString: url]]];
        }
        
        [self.albumCovers addObject:albumCoverImage];
    }
    
//    NSLog(@"tracks: %@", self.tracks);
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
    NSLog(@"%lu", (unsigned long)[self.tracks count]);
    return [self.tracks count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    songCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSDictionary *track = [self.tracks objectAtIndex:indexPath.row];
//    NSLog(@"Track: %@", track);
    [cell setData:track];
    
    //to change background color of selected cell
    UIView *backgroundView          = [[UIView alloc] init];
    backgroundView.backgroundColor  = [UIColor colorWithRed:0x59/255.0 green:0x69/255.0 blue:0x80/255.0 alpha:1.0];
    cell.selectedBackgroundView     = backgroundView;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *track = [self.tracks objectAtIndex:indexPath.row];
    
    float tableViewHeight = [self.screenSize[@"height"] floatValue];
    tableViewHeight = 400.0;
    self.tableView.frame = CGRectMake(0, 264.0, 400.0, tableViewHeight);
    
    if (self.tableView.frame.origin.y == 264.0) {
        self.albumCover.hidden = NO;
        NSLog(@"%@", self.albumCover.image = self.albumCovers[indexPath.row]);
    }
    else {
        NSLog(@"%f", self.tableView.frame.origin.y);
    }
    
    // PLAY SONG
    songCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor colorWithRed:0x59/255.0 green:0x69/255.0 blue:0x80/255.0 alpha:1.0];

    NSURL *trackURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.soundcloud.com/tracks/%@/stream?client_id=%@", track[@"id"], kClientId]];
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:trackURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // self.player is strong property
        self.player = [[AVAudioPlayer alloc] initWithData:data error:nil];
        [self.player play];
    }];
    
    [task resume];
}

-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:0x59/255.0 green:0x69/255.0 blue:0x80/255.0 alpha:1.0];
}

-(void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:0x1F/255.0 green:0x32/255.0 blue:0x4D/255.0 alpha:1.0];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // STYLE
    songCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor colorWithRed:0x1F/255.0 green:0x32/255.0 blue:0x4D/255.0 alpha:1.0];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (void) updatePlayerBackground
{
//    NSString* url = [self.nowPlayingTrack[@"artwork_url"] stringByReplacingOccurrencesOfString:@"large"
//                                                        withString:@"crop"];
//    UIImage* albumCoverImage = [UIImage imageWithData:
//                                [NSData dataWithContentsOfURL:
//                                 [NSURL URLWithString: url]]];

    
    // SLIDE THE TABLE VIEW DOWN
//    [self slideTableView];
    
    
}

- (void) slideTableView
{
}

- (void) setAlbumCovers
{
    // do asyncronously
//    for (NSDictionary* track in self.tracks) {
//        NSString* url = [track[@"artwork_url"] stringByReplacingOccurrencesOfString:@"large"                                                        withString:@"crop"];
//        UIImage* albumCoverImage = [UIImage imageWithData:
//                                    [NSData dataWithContentsOfURL:
//                                     [NSURL URLWithString: url]]];
//        
//        [self.albumCovers addObject:albumCoverImage];
//    }
}

@end
