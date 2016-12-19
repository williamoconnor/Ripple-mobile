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
        self.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
        
        self.layer.cornerRadius = 5.0;
        self.layer.borderWidth = 2.0;
        self.layer.borderColor = [cPrimaryPink CGColor];
        
        // UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 40.0)];
        
        self.emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(frame.size.width/2 - 100, 40.0, 200.0, 40.0)];
        self.emailTextField.placeholder = @"email";
        self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
        self.emailTextField.backgroundColor = cWhite;
        self.emailTextField.layer.cornerRadius = 4.0;
        self.emailTextField.layer.borderWidth = 1.0;
        self.emailTextField.layer.borderColor = [cPrimaryNavy CGColor];
        UIView *emailPaddingView = [[UIView alloc] initWithFrame:CGRectMake(self.emailTextField.frame.origin.x, self.emailTextField.frame.origin.y, 15, 40.0)];
        self.emailTextField.leftView = emailPaddingView;
        self.emailTextField.leftViewMode = UITextFieldViewModeAlways;
        self.emailTextField.font = [UIFont fontWithName:@"Avenir Next" size:18.0];
        self.emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.emailTextField.textColor = cPrimaryNavy;
        self.emailTextField.delegate = self;
        [self addSubview: self.emailTextField];
        
        self.passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(frame.size.width/2 - 100, 100.0, 200.0, 40.0)];
        self.passwordTextField.placeholder = @"password";
        self.passwordTextField.secureTextEntry = true;
        self.passwordTextField.backgroundColor = cWhite;
        self.passwordTextField.layer.cornerRadius = 4.0;
        self.passwordTextField.layer.borderWidth = 1.0;
        self.passwordTextField.layer.borderColor = [cPrimaryNavy CGColor];
        UIView *passwordPaddingView = [[UIView alloc] initWithFrame:CGRectMake(self.passwordTextField.frame.origin.x, self.passwordTextField.frame.origin.y, 15, 40.0)];
        self.passwordTextField.leftView = passwordPaddingView;
        self.passwordTextField.leftViewMode = UITextFieldViewModeAlways;
        self.passwordTextField.font = [UIFont fontWithName:@"Avenir Next" size:18.0];
        self.passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.passwordTextField.textColor = cPrimaryNavy;
        self.passwordTextField.delegate = self;
        [self addSubview: self.passwordTextField];
        
        self.submitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.submitButton.frame = CGRectMake(frame.size.width/2 - 100, 160.0, 200.0, 40.0);
        [self.submitButton setTitle: @"Login" forState:UIControlStateNormal];
        self.submitButton.backgroundColor = cPrimaryPink;
        self.submitButton.tintColor = cWhite;
        self.submitButton.layer.cornerRadius = 4.0;
        [self.submitButton addTarget:self action:@selector(loginButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        self.submitButton.titleLabel.font = [UIFont fontWithName:@"Avenir Next" size:20.0];
        [self addSubview:self.submitButton];
        
        UIButton* newUserButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        newUserButton.frame = CGRectMake(frame.size.width/2 - 50, 200.0, 100.0, 40.0);
        [newUserButton setTitle: @"New User?" forState:UIControlStateNormal];
        newUserButton.tintColor = cPrimaryPink;
        newUserButton.titleLabel.font = [UIFont fontWithName:@"Avenir Next" size:14.0];
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

-(void) slideForm:(UIView*)form up:(BOOL)up
{
    [self.delegate slideForm:form up:up];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    [self slideForm:self up:YES];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    if (!([self.emailTextField isFirstResponder] || [self.passwordTextField isFirstResponder])) {
        [self slideForm:self up:NO];
    }
}

@end
