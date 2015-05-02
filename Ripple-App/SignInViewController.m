//
//  SignInViewController.m
//  Ripple-App
//
//  Created by William O'Connor on 4/30/15.
//  Copyright (c) 2015 Gooey Dee Bee. All rights reserved.
//

#import "SignInViewController.h"
#import "DataManager.h"

@interface SignInViewController ()

@property (strong, nonatomic) UITextField* emailField;
@property (strong, nonatomic) UITextField* passwordField;

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSDictionary *screen = [[NSUserDefaults standardUserDefaults] objectForKey:@"screen"];
    self.view.backgroundColor = [UIColor colorWithRed:0x48/255.0 green:0x98/255.0 blue:0xBD/255.0 alpha:1.0];
    
    // GET EMAIL
    self.emailField = [[UITextField alloc] initWithFrame:CGRectMake(0.2*[screen[@"width"] floatValue], 0.2*[screen[@"height"] floatValue], 0.6*[screen[@"width"] floatValue], 40.0)];
    self.emailField.placeholder = @"Email";
    self.emailField.font = [UIFont fontWithName:@"Poiret One" size:14.0];
    self.emailField.backgroundColor = [UIColor whiteColor];
    self.emailField.borderStyle = UITextBorderStyleRoundedRect;
//    [self.emailField.layer setBorderColor:[UIColor colorWithRed:0x1F/255.0 green:0x32/255.0 blue:0x4D/255.0 alpha:1.0].CGColor];
//    [self.emailField.layer setBorderWidth:1.0];
    self.emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self.view addSubview: self.emailField];
    
    // GET PASSWORD
    self.passwordField = [[UITextField alloc] initWithFrame:CGRectMake(0.2*[screen[@"width"] floatValue], 0.3*[screen[@"height"] floatValue], 0.6*[screen[@"width"] floatValue], 40.0)];
    self.passwordField.placeholder = @"Password";
    self.passwordField.font = [UIFont fontWithName:@"Poiret One" size:14.0];
    self.passwordField.backgroundColor = [UIColor whiteColor];
    self.passwordField.borderStyle = UITextBorderStyleRoundedRect;
    self.passwordField.secureTextEntry = YES;
    //    [self.emailField.layer setBorderColor:[UIColor colorWithRed:0x1F/255.0 green:0x32/255.0 blue:0x4D/255.0 alpha:1.0].CGColor];
    //    [self.emailField.layer setBorderWidth:1.0];
    self.passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self.view addSubview: self.passwordField];
    
    
    // SUBMIT
    UIButton* signInButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    signInButton.frame = CGRectMake([screen[@"width"] floatValue]/2 - 50.0, 0.4*[screen[@"height"] floatValue], 100.0, 40.0);
    [signInButton addTarget:self
               action:@selector(submit)
     forControlEvents:UIControlEventTouchUpInside];
    [signInButton setTitle:@"Sign In" forState:UIControlStateNormal];
    signInButton.titleLabel.font = [UIFont fontWithName:@"Poiret One" size:18.0];
    [signInButton setTitleColor:[UIColor colorWithRed:0x48/255.0 green:0x98/255.0 blue:0xBD/255.0 alpha:1.0] forState:UIControlStateNormal];
    signInButton.backgroundColor = [UIColor whiteColor];
    [signInButton.layer setBorderColor:[UIColor colorWithRed:0x1F/255.0 green:0x32/255.0 blue:0x4D/255.0 alpha:1.0].CGColor];
    [signInButton.layer setBorderWidth:1.0];
    [self.view addSubview:signInButton];
    
    UIButton* cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    cancelButton.frame = CGRectMake([screen[@"width"] floatValue]/2 - 50.0, 0.4*[screen[@"height"] floatValue]+50, 100.0, 40.0);
    [cancelButton addTarget:self
                     action:@selector(cancel)
           forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancelButton.backgroundColor = [UIColor clearColor];
    cancelButton.titleLabel.font = [UIFont fontWithName:@"Poiret One" size:14.0];
    [self.view addSubview:cancelButton];
    
    
    
    
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

- (void) submit
{
    //check login
    NSMutableDictionary* credentials = [[NSMutableDictionary alloc] init];
    credentials[@"password"] = self.passwordField.text;
    credentials[@"email"] = self.emailField.text;
    NSDictionary* result = [DataManager signIn:credentials];
    if ([result[@"result"] isEqualToString:@"success"]) {
        [[NSUserDefaults standardUserDefaults] setObject:self.emailField.text forKey:@"email"];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        UIAlertView* failedLogin = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"No account found with matching email/password pair" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [failedLogin show];
    }
}

- (void) cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
