//
//  accountStatusHeader.m
//  Ripple-App
//
//  Created by William O'Connor on 12/11/16.
//  Copyright © 2016 Ripple, LLC. All rights reserved.
//

#import "accountStatusHeader.h"
#import "Strings.h"
#import "Colors.h"
#import "Rankings.h"

@interface accountStatusHeader ()

@property (strong, nonatomic) UILabel* emailLabel;

@end

@implementation accountStatusHeader

-(id)initWithWidth:(float)width andRank:(int)rank andPoints:(float)points
{
    CGRect frame = CGRectMake(0.0, 0.0, width, 240);
    self = [super initWithFrame:frame];
    
    if (self) {
        //NAV TITLE
        /*
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake([self.screenSize[@"width"] floatValue]/2 - 72.5, 18.0, 145.0, 40.0)];
        NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIFont fontWithName:@"Avenir" size:28.0], NSFontAttributeName,
                                    cWhite, NSForegroundColorAttributeName,
                                    nil];
        NSMutableAttributedString* navTitle = [[NSMutableAttributedString alloc] initWithString:@"account" attributes:attributes];
        [navTitle addAttribute:NSKernAttributeName
                         value:@(2.0)
                         range:NSMakeRange(0, 6)];
        titleLabel.attributedText = navTitle;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [statusHeader addSubview:titleLabel];
        */
        
        self.backgroundColor = cWhite;
        
        //BACK BUTTON
        self.backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.backButton.frame = CGRectMake(12.0, 32.0, 50.0, 21.0);
        [self.backButton setTintColor:cPrimaryPink];
        [self.backButton setTitle:@"Back" forState:UIControlStateNormal];
        [self.backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        self.backButton.titleLabel.font = [UIFont fontWithName:@"Avenir Next" size:17];
        [self addSubview:self.backButton];
        
        // LOGOUT BUTTON
        self.logoutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.logoutButton.frame = CGRectMake(frame.size.width - 82.0, 32.0, 70.0, 21.0);
        [self.logoutButton setTintColor:cPrimaryPink];
        [self.logoutButton setTitle:@"Logout" forState:UIControlStateNormal];
        [self.logoutButton addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
        self.logoutButton.titleLabel.font = [UIFont fontWithName:@"Avenir Next" size:17];
        [self addSubview:self.logoutButton];
        
        // DROP VIEW
        self.dropView = [[accountStatusDropIcon alloc] initWithFrame:CGRectMake((width-150)/2, 40, 150, 170)];
        // construct gradient
        [self.dropView.layer insertSublayer:[self createGradientForPoints:points andRank:rank] atIndex:0];
        [self addSubview:self.dropView];
        
        //EMAIL LABEL
        self.emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 200.0, frame.size.width, 20)];
        self.emailLabel.font = [UIFont fontWithName:@"Avenir Next" size:18.0];
        self.emailLabel.textColor = cPrimaryLightBlue;
        self.emailLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview: self.emailLabel];
        
        // BOTTOM BORDER
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.backgroundColor = cPrimaryPink.CGColor;
        bottomBorder.frame = CGRectMake(0, self.frame.size.height-2, width, 2);
        [self.layer addSublayer:bottomBorder];
    }
    
    return self;
}

-(CAGradientLayer*) createGradientForPoints:(float)points andRank:(int)rank
{
    UIColor* currentRankColor = [Rankings getRankingToUIColor:rank];
    UIColor* nextRankColor = [Rankings getRankingToUIColor:(rank+1)];
    float progress = 1-[Rankings getPointsToProgress:points]-0.2;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.dropView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[currentRankColor CGColor], (id)[nextRankColor CGColor], nil];
    gradient.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:progress], [NSNumber numberWithFloat:progress + 0.4], nil];
    return gradient;
}

-(void)back
{
    [self.delegate back];
}

-(void)logout
{
    [self.delegate logout];
}

-(void)setEmail:(NSString *)email
{
    self.emailLabel.text = email;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
