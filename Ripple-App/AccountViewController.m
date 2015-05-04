//
//  AccountViewController.m
//  Ripple-App
//
//  Created by William O'Connor on 5/1/15.
//  Copyright (c) 2015 Gooey Dee Bee. All rights reserved.
//

#import "AccountViewController.h"
#import "DataManager.h"

@interface AccountViewController ()

@property (strong, nonatomic) NSDictionary* userAccount;

@end

@implementation AccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSDictionary *screen = [[NSUserDefaults standardUserDefaults] objectForKey:@"screen"];
    self.view.backgroundColor = [UIColor colorWithRed:0x48/255.0 green:0x98/255.0 blue:0xBD/255.0 alpha:1.0];
    
    // user account
    self.userAccount = [DataManager getUserInfo:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]];
    NSLog(@"account: %@", self.userAccount);
    
    // EMAIL LABEL
    UILabel* emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.1*[screen[@"height"] floatValue]+50, [screen[@"width"] floatValue], 40.0)];
    [emailLabel setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]];
    emailLabel.textAlignment = NSTextAlignmentCenter;
    emailLabel.textColor = [UIColor whiteColor];
    emailLabel.font = [UIFont fontWithName:@"Poiret One" size:24.0];
    [self.view addSubview:emailLabel];
    
    // CANCEL BUTTON
    UIButton* cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    cancelButton.frame = CGRectMake([screen[@"width"] floatValue]/2 - 50.0, 0.9*[screen[@"height"] floatValue]-50.0, 100.0, 40.0);
    [cancelButton addTarget:self
                     action:@selector(cancel)
           forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancelButton.backgroundColor = [UIColor clearColor];
    cancelButton.titleLabel.font = [UIFont fontWithName:@"Poiret One" size:14.0];
    [self.view addSubview:cancelButton];
    
    // LOGOUT BUTTON
    UIButton* logoutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    logoutButton.frame = CGRectMake([screen[@"width"] floatValue]/2 - 50.0, 0.8*[screen[@"height"] floatValue]-50.0, 100.0, 40.0);
    [logoutButton addTarget:self
                     action:@selector(logout)
           forControlEvents:UIControlEventTouchUpInside];
    [logoutButton setTitle:@"Logout" forState:UIControlStateNormal];
    [logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    logoutButton.backgroundColor = [UIColor colorWithRed:0xE8/255.0 green:0x64/255.0 blue:0x64/255.0 alpha:1.0];
    logoutButton.titleLabel.font = [UIFont fontWithName:@"Poiret One" size:14.0];
    [self.view addSubview:logoutButton];
    
    // POINTS LABEL
    UILabel* pointsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.2*[screen[@"height"] floatValue]+50, [screen[@"width"] floatValue], 40.0)];
    [pointsLabel setText:[NSString stringWithFormat:@"Points: %@", self.userAccount[@"points"]]];
    pointsLabel.textAlignment = NSTextAlignmentCenter;
    pointsLabel.textColor = [UIColor whiteColor];
    pointsLabel.font = [UIFont fontWithName:@"Poiret One" size:24.0];
    [self.view addSubview:pointsLabel];
    
    //DROPS LABEL
    UILabel* dropsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.3*[screen[@"height"] floatValue]+50, [screen[@"width"] floatValue], 40.0)];
    [dropsLabel setText:[NSString stringWithFormat:@"Total Drops: %@", self.userAccount[@"total_drops"]]];
    dropsLabel.textAlignment = NSTextAlignmentCenter;
    dropsLabel.textColor = [UIColor whiteColor];
    dropsLabel.font = [UIFont fontWithName:@"Poiret One" size:24.0];
    [self.view addSubview:dropsLabel];
    
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

- (void) cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) logout
{
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"email"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
