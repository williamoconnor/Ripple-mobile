//
//  SignInViewController.m
//  Ripple-App
//
//  Created by William O'Connor on 4/30/15.
//  Copyright (c) 2015 Ripple. All rights reserved.
//

#import "SignInViewController.h"
#import "DataManager.h"
#import "Colors.h"

@interface SignInViewController ()

@property (strong, nonatomic) UITextField* emailField;
@property (strong, nonatomic) UITextField* passwordField;
@property (strong, nonatomic) NSMutableDictionary* screenSize;

@end

@implementation SignInViewController

-(NSMutableDictionary*)screenSize
{
    if (!_screenSize) {
        _screenSize = [[NSMutableDictionary alloc] init];
    }
    return _screenSize;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    NSNumber *height = [[NSNumber alloc] initWithDouble:screenHeight];
    NSNumber *width = [[NSNumber alloc] initWithDouble:screenWidth];
    
    self.screenSize[@"height"] = height;
    self.screenSize[@"width"] = width;
    
    [[NSUserDefaults standardUserDefaults] setObject:self.screenSize forKey:@"screen"];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = cSlateNavy;
    
    // video background
    //Not affecting background music playing
    NSError *sessionError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&sessionError];
    [[AVAudioSession sharedInstance] setActive:YES error:&sessionError];
    
    //Set up player
    NSURL *movieURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"ripple_login" ofType:@"mp4"]];
    AVAsset *avAsset = [AVAsset assetWithURL:movieURL];
    AVPlayerItem *avPlayerItem =[[AVPlayerItem alloc]initWithAsset:avAsset];
    self.avplayer = [[AVPlayer alloc]initWithPlayerItem:avPlayerItem];
    AVPlayerLayer *avPlayerLayer =[AVPlayerLayer playerLayerWithPlayer:self.avplayer];
    [avPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [avPlayerLayer setFrame:[[UIScreen mainScreen] bounds]];
    self.videoView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.videoView.layer addSublayer:avPlayerLayer];
    [self.view addSubview:self.videoView];
    
    //Config player
    [self.avplayer seekToTime:kCMTimeZero];
    [self.avplayer setVolume:0.0f];
    [self.avplayer setActionAtItemEnd:AVPlayerActionAtItemEndNone];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.avplayer currentItem]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerStartPlaying)
                                             name:UIApplicationDidBecomeActiveNotification object:nil];
    
    
    
    self.loginView = [[LoginView alloc] initWithFrame:CGRectMake(20.0, 180.0, [self.screenSize[@"width"] floatValue] - 40.0, 260)];
    self.loginView.delegate = self;
    self.loginView.alpha = 0;
    self.registerView = [[RegisterView alloc] initWithFrame:CGRectMake(20.0, 180.0, [self.screenSize[@"width"] floatValue] - 40.0, 300)];
    self.registerView.delegate = self;
    self.registerView.alpha = 0;
    [self.view addSubview:self.loginView];
    [self.view addSubview:self.registerView];
    
    self.logoContainer = [[UIImageView alloc] initWithFrame:CGRectMake(([width floatValue]/2) - 106, 80, 213, 66)];
    self.logoContainer.image = [UIImage imageNamed:@"logo-text-only.png"];
    self.logoContainer.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.logoContainer];
    
//    self.betaLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.logoContainer.frame.origin.x, self.logoContainer.frame.origin.y + self.logoContainer.frame.size.height, self.logoContainer.frame.size.width, 24)];
//    self.betaLabel.text = @"beta";
//    self.betaLabel.font = [UIFont fontWithName:@"Avenir Next" size:20.0];
//    self.betaLabel.textColor = [UIColor whiteColor];
//    self.betaLabel.textAlignment = NSTextAlignmentCenter;
//    [self.view addSubview:self.betaLabel];
    
    self.loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.loginButton.frame = CGRectMake(0, [height floatValue] - 56, [width floatValue]/2, 56);
    self.loginButton.backgroundColor = cPrimaryPink;
    [self.loginButton setTitleColor:cWhite forState:UIControlStateNormal];
    [self.loginButton setTitle:@"sign in" forState:UIControlStateNormal];
    self.loginButton.titleLabel.font = [UIFont fontWithName:@"Avenir Next" size:20.0];
    [self.loginButton addTarget:self action:@selector(showLoginView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.loginButton];
    
    self.registerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.registerButton.frame = CGRectMake([width floatValue]/2, [height floatValue] - 56, [width floatValue]/2, 56);
    self.registerButton.backgroundColor = cPrimaryNavy;
    [self.registerButton setTitleColor:cWhite forState:UIControlStateNormal];
    [self.registerButton setTitle:@"register" forState:UIControlStateNormal];
    self.registerButton.titleLabel.font = [UIFont fontWithName:@"Avenir Next" size:20.0];
    [self.registerButton addTarget:self action:@selector(showRegisterView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.registerButton];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) dismissKeyboard
{
    [self.loginView.emailTextField resignFirstResponder];
    [self.loginView.passwordTextField resignFirstResponder];
    [self.registerView.emailTextField resignFirstResponder];
    [self.registerView.passwordTextField resignFirstResponder];
    [self.registerView.confirmPasswordTextField resignFirstResponder];
}

-(void) showLoginView
{
    // hide buttons and register
    [UIView animateWithDuration:1.0 animations:^{
        self.registerView.alpha = 0.0;
        self.registerButton.alpha = 0.0;
        self.loginButton.alpha = 0.0;
    } completion:^(BOOL finished) {
        // show login
        [UIView animateWithDuration:1.0 animations:^{
            self.loginView.alpha = 1.0;
            [self fadeLogoOut:NO];
        }];
    }];
}

-(void) showRegisterView
{
    // hide buttons and login
    [UIView animateWithDuration:1.0 animations:^{
        self.loginView.alpha = 0.0;
        self.registerButton.alpha = 0.0;
        self.loginButton.alpha = 0.0;
    } completion:^(BOOL finished) {
        // show register
        [UIView animateWithDuration:1.0 animations:^{
            self.registerView.alpha = 1.0;
            [self fadeLogoOut:NO];
        }];
    }];
}

#pragma mark - login delegate

- (void) loginUser:(NSMutableDictionary *)credentials
{
    NSLog(@"%@", credentials);
    NSDictionary* result = [DataManager login:credentials];
    if ([result[@"result"] isEqualToString:@"success"]) {
//        NSLog(@"%@", result);
        [[NSUserDefaults standardUserDefaults] setObject:result[@"user"] forKey:@"user"];
        NSLog(@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"user"]);
        [self performSegueWithIdentifier:@"loginSegue" sender:nil];
    }
    else {
        UIAlertView* failed = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"Please try again." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [failed show];
    }
}

- (void) newUser
{
    [self showRegisterView];
}

-(void) toLogin
{
    [self showLoginView];
}

#pragma mark - register delegate

-(void) registerUser:(NSMutableDictionary *)credentials
{
    NSDictionary* result = [DataManager registerUser:credentials];
    if (result[@"_id"]) {
        [[NSUserDefaults standardUserDefaults] setObject:result forKey:@"user"];
        NSLog(@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"user"]);
        [self performSegueWithIdentifier:@"loginSegue" sender:nil];
    }
    else {
        UIAlertView* failed = [[UIAlertView alloc] initWithTitle:@"Registration Failed" message:@"Please try again." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [failed show];
    }
}

#pragma mark - video stuff
- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

-(void)playerStartPlaying
{
    [self.avplayer play];
}

#pragma mark - slide view
-(void) slideForm:(UIView*)form up:(BOOL)up
{
    if (up == true) {
        [UIView animateWithDuration:0.4 animations:^{
            [self fadeLogoOut:up];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.4 animations:^{
                [form setFrame:[self newFrameForView:form atTop:up]];
            }];
        }];
    }
    else {
        [UIView animateWithDuration:0.4 animations:^{
            [form setFrame:[self newFrameForView:form atTop:up]];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.4 animations:^{
                [self fadeLogoOut:up];
            }];
        }];
    }
}

-(void) fadeLogoOut:(BOOL)hidden
{
    if (hidden == true) {
        self.logoContainer.alpha = 0.0;
//        self.betaLabel.alpha = 0.0;
    }
    else {
        self.logoContainer.alpha = 1.0;
//        self.betaLabel.alpha = 1.0;
    }
}

-(CGRect) newFrameForView:(UIView*)view atTop:(BOOL)top
{
    CGRect originalFrame = view.frame;
    float y;
    
    if (view.frame.origin.y == self.logoContainer.frame.origin.y - 60 && top == false) {
        y = 180;
        return CGRectMake(originalFrame.origin.x, y, originalFrame.size.width, originalFrame.size.height);
    }
    
    else if (view.frame.origin.y == 180 && top == true) {
        y = self.logoContainer.frame.origin.y - 60;
        return CGRectMake(originalFrame.origin.x, y, originalFrame.size.width, originalFrame.size.height);
    }
    else {
        return originalFrame;
    }
}

@end
