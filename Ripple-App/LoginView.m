//
//  LoginView.m
//  Ripple-App
//
//  Created by William O'Connor on 9/6/15.
//  Copyright (c) 2015 Ripple. All rights reserved.
//

#import "LoginView.h"
#import "Colors.h"

@implementation LoginView
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
        
        self.submitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.submitButton.frame = CGRectMake(frame.size.width/2 - 100, 140.0, 200.0, 40.0);
        [self.submitButton setTitle: @"Login" forState:UIControlStateNormal];
        self.submitButton.backgroundColor = cWhite;
        self.submitButton.tintColor = cPrimaryRed;
        [self.submitButton addTarget:self action:@selector(loginButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.submitButton];
        
        UIButton* newUserButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        newUserButton.frame = CGRectMake(frame.size.width/2 - 50, 200.0, 100.0, 40.0);
        [newUserButton setTitle: @"New User?" forState:UIControlStateNormal];
        newUserButton.tintColor = cWhite;
        [newUserButton addTarget:self action:@selector(newUserButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:newUserButton];
    }
    
    return self;
}

- (void) loginButtonPressed
{
    NSMutableDictionary* credentials = [[NSMutableDictionary alloc] init];
    credentials[@"email"] = self.emailTextField.text;
    credentials[@"password"] = self.passwordTextField.text;
    
    NSLog(@"%@", credentials);
    
    [self.delegate loginUser:credentials];
}

- (void) newUserButtonPressed
{
    [self.delegate newUser];
}

@end
