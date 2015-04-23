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
@property (strong, nonatomic) IBOutlet UIImageView *playerBackgroundImageView;

@end

@implementation ViewController

-(NSMutableArray*)tracks
{
    if (!_tracks) {
        _tracks = [[NSMutableArray alloc] init];
    }
    return _tracks;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor colorWithRed:0x19/255.0 green:0x66/255.0 blue:0xA8/255.0 alpha:1.0];
    [self.tableView registerClass:[songCell class] forCellReuseIdentifier:@"cell"];
    self.playerBackgroundImageView.image = [UIImage imageNamed:@"NowPlaying.png"];
    
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
    [self.locationManager stopUpdatingLocation];
}

-(void) locationManager: (CLLocationManager *)manager didUpdateToLocation: (CLLocation *) newLocation
           fromLocation: (CLLocation *) oldLocation {
    NSLog(@"HERE");
    CLLocation *location = newLocation;
    // Configure the new event with information from the location
    CLLocationCoordinate2D coordinate = [location coordinate];
    
    float longitude = coordinate.longitude;
    float latitude = coordinate.latitude;
    
    
    NSLog(@"lati: %f", latitude);
    
    int lat = (int) latitude;
    int lon = (int) longitude;
    
    NSString *latS = [NSString stringWithFormat:@"%i", lat];
    NSString *lonS = [NSString stringWithFormat:@"%i", lon];
    
    [[NSUserDefaults standardUserDefaults] setObject:latS forKey:@"latitude"];
    [[NSUserDefaults standardUserDefaults] setObject:lonS forKey:@"longitude"];
    
    [self loadSongs];
    [self.locationManager stopUpdatingLocation];
    
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
    NSNumber *tempNumber = [[NSNumber alloc] initWithDouble:32.8];
    location[@"latitude"] = tempNumber;
    NSNumber *tempNumber2 = [[NSNumber alloc] initWithDouble:-96.7];
    location[@"longitude"] = tempNumber2;
    
    NSDictionary* songs = [DataManager getSongList:location];
//    NSLog(@"songs: %@", songs);
    
    for (NSDictionary* song_id in songs) {
//        NSLog(@"song id: %@", song_id[@"song_id"]);
        NSDictionary* track = [DataManager getTrackInfo:song_id[@"song_id"]];
        
        [self.tracks addObject: track];
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
    return [self.tracks count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    songCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSDictionary *track = [self.tracks objectAtIndex:indexPath.row];
    NSLog(@"Track: %@", track);
    [cell setData:track];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // STYLE
    songCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor colorWithRed:0xBB/255.0 green:0xDF/255.0 blue:0xF0/255.0 alpha:1.0];
    cell.titleLabel.textColor = [UIColor colorWithRed:0x19/255.0 green:0x66/255.0 blue:0xA8/255.0 alpha:1.0];
    cell.artistLabel.textColor = [UIColor colorWithRed:0x48/255.0 green:0x98/255.0 blue:0xBD/255.0 alpha:1.0];
    
    // PLAY SONG
    NSDictionary *track = [self.tracks objectAtIndex:indexPath.row];
    self.nowPlayingTrack = track;
    [self updatePlayerBackground];
    NSString *streamURL = track[@"stream_url"];
    
//    SCAccount *account = [SCSoundCloud account];
//    
//    [SCRequest performMethod:SCRequestMethodGET
//                  onResource:[NSURL URLWithString:streamURL]
//             usingParameters:nil
//                 withAccount:account
//      sendingProgressHandler:nil
//             responseHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//                 NSError *playerError;
//                 self.player = [[AVAudioPlayer alloc] initWithData:data error:&playerError];
//                 [self.player prepareToPlay];
//                 [self.player play];
//             }];
    
    
    
//    NSDictionary* myDictionary = [DataManager streamSong:[self.tracks objectAtIndex:indexPath.row]];
//    NSLog(@"%@", myDictionary);
//    NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:myDictionary];
//    NSError *playerError;
//    self.player =[[AVAudioPlayer alloc] initWithData:myData error:&playerError];
//    [self.player prepareToPlay];
//    [self.player play];
    
    
    NSURL *trackURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.soundcloud.com/tracks/%@/stream?client_id=%@", track[@"id"], kClientId]];
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:trackURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // self.player is strong property
        self.player = [[AVAudioPlayer alloc] initWithData:data error:nil];
        [self.player play];
    }];
    
    [task resume];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // STYLE
    songCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor colorWithRed:0x19/255.0 green:0x66/255.0 blue:0xA8/255.0 alpha:1.0];
    cell.titleLabel.textColor = [UIColor colorWithRed:0xE0/255.0 green:0xF5/255.0 blue:0xFF/255.0 alpha:1.0];
    cell.artistLabel.textColor = [UIColor colorWithRed:0xBB/255.0 green:0xDF/255.0 blue:0xF0/255.0 alpha:1.0];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (IBAction)getTracksButtonPressed:(UIButton *)sender {
//    SCAccount *account = [SCSoundCloud account];
//    if (account == nil) {
//        UIAlertView *alert = [[UIAlertView alloc]
//                              initWithTitle:@"Not Logged In"
//                              message:@"You must login first"
//                              delegate:nil
//                              cancelButtonTitle:@"OK"
//                              otherButtonTitles:nil];
//        [alert show];
//        return;
//    }
//    
//    SCRequestResponseHandler handler;
//    handler = ^(NSURLResponse *response, NSData *data, NSError *error) {
//        NSError *jsonError = nil;
//        NSJSONSerialization *jsonResponse = [NSJSONSerialization
//                                             JSONObjectWithData:data
//                                             options:0
//                                             error:&jsonError];
//        if (!jsonError && [jsonResponse isKindOfClass:[NSArray class]]) {
//            self.tracks = (NSArray *)jsonResponse;
//            [self.tableView reloadData];
//            NSLog(@"%@", self.tracks);
//        }
//        else {
//            NSLog(@"Didn't work");
//            NSLog(@"%@", jsonResponse);
//        }
//    };
//    
//    NSString *resourceURL = @"https://api.soundcloud.com/me/tracks.json";
//    [SCRequest performMethod:SCRequestMethodGET
//                  onResource:[NSURL URLWithString:resourceURL]
//             usingParameters:nil
//                 withAccount:account
//      sendingProgressHandler:nil
//             responseHandler:handler];

}


- (IBAction)signInButtonPressed:(UIButton *)sender {
    
    SCLoginViewControllerCompletionHandler handler = ^(NSError *error) {
        if (SC_CANCELED(error)) {
            NSLog(@"Canceled!");
        } else if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            NSLog(@"Done!");
        }
    };
    
    [SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL) {
        SCLoginViewController *loginViewController;
        
        loginViewController = [SCLoginViewController
                               loginViewControllerWithPreparedURL:preparedURL
                               completionHandler:handler];
        [self presentViewController:loginViewController animated:YES completion:nil];
    }];
}

- (void) updatePlayerBackground
{
    NSString* url = [self.nowPlayingTrack[@"artwork_url"] stringByReplacingOccurrencesOfString:@"large"
                                                        withString:@"crop"];
    UIImage* albumCoverImage = [UIImage imageWithData:
                                [NSData dataWithContentsOfURL:
                                 [NSURL URLWithString: url]]];
    
    self.playerBackgroundImageView.image = albumCoverImage;
}


@end
