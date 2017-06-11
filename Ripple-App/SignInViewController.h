//
//  SignInViewController.h
//  Ripple-App
//
//  Created by William O'Connor on 4/30/15.
//  Copyright (c) 2015 Ripple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginView.h"
#import "RegisterView.h"
#import <AVFoundation/AVFoundation.h>

@interface SignInViewController : UIViewController <loginProtocol, registerProtocol>

@property (strong, nonatomic) LoginView* loginView;
@property (strong, nonatomic) RegisterView* registerView;

//@property (strong, nonatomic) UILabel* betaLabel;
@property (strong, nonatomic) UIButton* loginButton;
@property (strong, nonatomic) UIButton* registerButton;
@property (strong, nonatomic) UIImageView* logoContainer;

@property (strong, nonatomic) UIView* videoView;
@property (strong, nonatomic) AVPlayer* avplayer;

-(void) playerStartPlaying;

@end
