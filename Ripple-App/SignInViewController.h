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

@interface SignInViewController : UIViewController <loginProtocol, registerProtocol>

@property (strong, nonatomic) LoginView* loginView;
@property (strong, nonatomic) RegisterView* registerView;

@end
