//
//  RegisterView.m
//  Ripple-App
//
//  Created by William O'Connor on 9/6/15.
//  Copyright (c) 2015 Ripple. All rights reserved.
//

#import "RegisterView.h"
#import "Colors.h"

@implementation RegisterView

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        // initialize
        self.backgroundColor = cPrimaryRed;
        
        self.emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(frame.size.width/2 - 100, 20.0, 200.0, 40.0)];
        self.emailTextField.placeholder = @"Email";
        self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
        self.emailTextField.backgroundColor = cWhite;
        [self addSubview: self.emailTextField];
        
        self.passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(frame.size.width/2 - 100, 80.0, 200.0, 40.0)];
        self.passwordTextField.placeholder = @"Password";
        self.passwordTextField.secureTextEntry = true;
        self.passwordTextField.backgroundColor = cWhite;
        [self addSubview: self.passwordTextField];
        
        self.confirmPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(frame.size.width/2 - 100, 140.0, 200.0, 40.0)];
        self.confirmPasswordTextField.placeholder = @"Confirm Password";
        self.confirmPasswordTextField.secureTextEntry = true;
        self.confirmPasswordTextField.backgroundColor = cWhite;
        [self addSubview: self.confirmPasswordTextField];
        
        self.submitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.submitButton.frame = CGRectMake(frame.size.width/2 - 50, 200.0, 100.0, 40.0);
        [self.submitButton setTitle: @"Submit" forState:UIControlStateNormal];
        self.submitButton.backgroundColor = cWhite;
        self.submitButton.tintColor = cPrimaryRed;
        [self.submitButton addTarget:self action:@selector(registerButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.submitButton];
 
        UIButton* loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        loginButton.frame = CGRectMake(frame.size.width/2 - 50, 240.0, 100.0, 40.0);
        [loginButton setTitle: @"Login" forState:UIControlStateNormal];
        loginButton.tintColor = cWhite;
        [loginButton addTarget:self action:@selector(loginButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:loginButton];
        
    }
    
    return self;
}

- (void) registerButtonPressed
{
    NSMutableDictionary* credentials = [[NSMutableDictionary alloc] init];
    credentials[@"email"] = self.emailTextField.text;
    credentials[@"password"] = self.passwordTextField.text;
    credentials[@"confirmPassword"] = self.confirmPasswordTextField.text;
    
    [self.delegate registerUser:credentials];
}

-(void) loginButtonPressed
{
    [self.delegate toLogin];
}

@end
