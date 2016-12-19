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
- (void) slideForm:(UIView*)form up:(BOOL)up;

@end

@interface LoginView : UIView <UITextFieldDelegate>

- (id) initWithFrame:(CGRect)frame;
@property (nonatomic) id <loginProtocol> delegate;
@property (strong, nonatomic) UITextField* emailTextField;
@property (strong, nonatomic) UITextField* passwordTextField;
@property (strong, nonatomic) UIButton* submitButton;

@property BOOL editing;

@end
