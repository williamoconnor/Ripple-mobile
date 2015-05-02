//
//  AccountViewController.m
//  Ripple-App
//
//  Created by William O'Connor on 5/1/15.
//  Copyright (c) 2015 Gooey Dee Bee. All rights reserved.
//

#import "AccountViewController.h"

@interface AccountViewController ()

@end

@implementation AccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSDictionary *screen = [[NSUserDefaults standardUserDefaults] objectForKey:@"screen"];
    self.view.backgroundColor = [UIColor colorWithRed:0x48/255.0 green:0x98/255.0 blue:0xBD/255.0 alpha:1.0];
    
    UILabel* emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.1*[screen[@"height"] floatValue]+50, [screen[@"width"] floatValue], 40.0)];
    [emailLabel setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]];
    emailLabel.textAlignment = NSTextAlignmentCenter;
    emailLabel.textColor = [UIColor whiteColor];
    emailLabel.font = [UIFont fontWithName:@"Poiret One" size:24.0];
    [self.view addSubview:emailLabel];
    
    
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

@end
