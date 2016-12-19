//
//  GeneralLoadingScreen.m
//  Ripple-App
//
//  Created by William O'Connor on 12/18/16.
//  Copyright © 2016 Ripple, LLC. All rights reserved.
//

#import "GeneralLoadingScreen.h"
#import "Colors.h"
#import "DGActivityIndicatorView.h"

@implementation GeneralLoadingScreen

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        // color
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
        
        // loader
        DGActivityIndicatorView *activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeBallScaleRippleMultiple tintColor:cPrimaryPink size:120.0f];
        activityIndicatorView.frame = CGRectMake((frame.size.width-120)/2, 160.0f, 120.0f, 120.0f);
        [self addSubview:activityIndicatorView];
        [activityIndicatorView startAnimating];
        
        // label
        UILabel* loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake((frame.size.width-300)/2, 290, 300.0, 40.0)];
        loadingLabel.text = @"loading";
        loadingLabel.textColor = cPrimaryPink;
        loadingLabel.font = [UIFont fontWithName:@"Avenir" size:28.0];
        loadingLabel.numberOfLines = 0;
        loadingLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:loadingLabel];
    }
    
    return self;
}

@end
