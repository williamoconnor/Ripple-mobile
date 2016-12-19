//
//  RegisterView.h
//  Ripple-App
//
//  Created by William O'Connor on 9/6/15.
//  Copyright (c) 2015 Ripple. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol registerProtocol <NSObject>

- (void) registerUser:(NSMutableDictionary*)credentials;
- (void) toLogin;
- (void) slideForm:(UIView*)form up:(BOOL)up;

@end

@interface RegisterView : UIView <UITextFieldDelegate>

- (id) initWithFrame:(CGRect)frame;
@property (nonatomic) id <registerProtocol> delegate;
@property (strong, nonatomic) UITextField* emailTextField;
@property (strong, nonatomic) UITextField* passwordTextField;
@property (strong, nonatomic) UITextField* confirmPasswordTextField;
@property (strong, nonatomic) UIButton* submitButton;

@end
