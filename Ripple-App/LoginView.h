//
//  LoginView.h
//  Ripple-App
//
//  Created by William O'Connor on 9/6/15.
//  Copyright (c) 2015 Ripple. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol loginProtocol <NSObject>

- (void) loginUser:(NSMutableDictionary*)credentials;
- (void) newUser;

@end

@interface LoginView : UIView

- (id) initWithFrame:(CGRect)frame;
@property (nonatomic) id <loginProtocol> delegate;
@property (strong, nonatomic) UITextField* emailTextField;
@property (strong, nonatomic) UITextField* passwordTextField;
@property (strong, nonatomic) UIButton* submitButton;

@end
