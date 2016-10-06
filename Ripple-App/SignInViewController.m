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
    
    self.loginView = [[LoginView alloc] initWithFrame:CGRectMake(20.0, 0.2*[self.screenSize[@"height"] floatValue], [self.screenSize[@"width"] floatValue] - 40.0, 0.6*[self.screenSize[@"height"] floatValue])];
    self.loginView.delegate = self;
    self.registerView = [[RegisterView alloc] initWithFrame:CGRectMake(20.0, 0.2*[self.screenSize[@"height"] floatValue], [self.screenSize[@"width"] floatValue] - 40.0, 0.6*[self.screenSize[@"height"] floatValue])];
    self.registerView.delegate = self;
    [self.view addSubview:self.loginView];
    
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
    [self.loginView removeFromSuperview];
    [self.view addSubview:self.registerView];
}

-(void) toLogin
{
    [self.registerView removeFromSuperview];
    [self.view addSubview:self.loginView];
}

#pragma mark - register delegate

-(void) registerUser:(NSMutableDictionary *)credentials
{
    NSDictionary* result = [DataManager registerUser:credentials];
    if (result[@"_id"]) {
        [[NSUserDefaults standardUserDefaults] setObject:result forKey:@"user"];
        NSLog(@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"user"]);
        UIAlertView* success = [[UIAlertView alloc] initWithTitle:@"Verification Email Sent" message:@"Check you email and verify your account" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [success show];
    }
    else {
        UIAlertView* failed = [[UIAlertView alloc] initWithTitle:@"Registration Failed" message:@"Please try again." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [failed show];
    }
}


@end
