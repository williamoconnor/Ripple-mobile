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
        UIView *passwordPaddingView = [[UIView alloc] initWithFrame:CGRectMake(self.emailTextField.frame.origin.x, self.emailTextField.frame.origin.y, 15, 40.0)];
        self.passwordTextField.leftView = passwordPaddingView;
        self.passwordTextField.leftViewMode = UITextFieldViewModeAlways;
        self.passwordTextField.font = [UIFont fontWithName:@"Avenir Next" size:18.0];
        self.passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.passwordTextField.textColor = cPrimaryNavy;
        self.passwordTextField.delegate = self;
        [self addSubview: self.passwordTextField];
        
        self.confirmPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(frame.size.width/2 - 100, 160.0, 200.0, 40.0)];
        self.confirmPasswordTextField.placeholder = @"confirm password";
        self.confirmPasswordTextField.secureTextEntry = true;
        self.confirmPasswordTextField.backgroundColor = cWhite;
        self.confirmPasswordTextField.layer.cornerRadius = 4.0;
        self.confirmPasswordTextField.layer.borderWidth = 1.0;
        self.confirmPasswordTextField.layer.borderColor = [cPrimaryNavy CGColor];
        UIView *confirmPasswordPaddingView = [[UIView alloc] initWithFrame:CGRectMake(self.emailTextField.frame.origin.x, self.emailTextField.frame.origin.y, 15, 40.0)];
        self.confirmPasswordTextField.leftView = confirmPasswordPaddingView;
        self.confirmPasswordTextField.leftViewMode = UITextFieldViewModeAlways;
        self.confirmPasswordTextField.font = [UIFont fontWithName:@"Avenir Next" size:18.0];
        self.confirmPasswordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.confirmPasswordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.confirmPasswordTextField.textColor = cPrimaryNavy;
        self.confirmPasswordTextField.delegate = self;
        [self addSubview: self.confirmPasswordTextField];
        
        self.submitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.submitButton.frame = CGRectMake(frame.size.width/2 - 100, 220.0, 200.0, 40.0);
        [self.submitButton setTitle: @"Submit" forState:UIControlStateNormal];
        self.submitButton.backgroundColor = cPrimaryPink;
        self.submitButton.tintColor = cWhite;
        self.submitButton.layer.cornerRadius = 4.0;
        [self.submitButton addTarget:self action:@selector(registerButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        self.submitButton.titleLabel.font = [UIFont fontWithName:@"Avenir Next" size:20.0];
        [self addSubview:self.submitButton];
 
        UIButton* loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        loginButton.frame = CGRectMake(frame.size.width/2 - 50, 260.0, 100.0, 40.0);
        [loginButton setTitle: @"Login" forState:UIControlStateNormal];
        loginButton.tintColor = cPrimaryPink;
        loginButton.font = [UIFont fontWithName:@"Avenir Next" size:14.0];
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
    [self.emailTextField resignFirstResponder];
    [self.confirmPasswordTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    
    [self.delegate toLogin];
}

-(void) slideForm:(UIView*)form up:(BOOL)up
{
    [self.delegate slideForm:form up:up];
}

#pragma mark - text field

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    [self slideForm:self up:YES];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    [self performSelector:@selector(checkSlideDown) withObject:nil afterDelay:0.8];
}

-(void)checkSlideDown {
    if (!([self.emailTextField isFirstResponder] || [self.passwordTextField isFirstResponder] || [self.confirmPasswordTextField isFirstResponder])) {
        [self slideForm:self up:NO];
    }
}

@end
