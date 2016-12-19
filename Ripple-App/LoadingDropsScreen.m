//
//  LoadingScreen.m
//  
//
//  Created by William O'Connor on 12/18/16.
//
//

#import "LoadingDropsScreen.h"
#import "Colors.h"
#import "DGActivityIndicatorView.h"

@implementation LoadingDropsScreen

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
        // logo
        UIImageView* logoView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width-300)/2, 100, 300, 81)];
        UIImage* logo = [UIImage imageNamed:@"logo-drop-next-to-text.png"];
        logoView.image = logo;
        [self addSubview:logoView];
        // color
        self.backgroundColor = cWhite;
        
        // loader
        DGActivityIndicatorView *activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeBallScaleRippleMultiple tintColor:cPrimaryPink size:80.0f];
        activityIndicatorView.frame = CGRectMake((frame.size.width-80)/2, 210.0f, 80.0f, 80.0f);
        [self addSubview:activityIndicatorView];
        [activityIndicatorView startAnimating];
        
        // label
        UILabel* loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake((frame.size.width-300)/2, 320, 300.0, 40.0)];
        loadingLabel.text = @"loading drops for your area";
        loadingLabel.textColor = cPrimaryPink;
        loadingLabel.font = [UIFont fontWithName:@"Avenir" size:24.0];
        loadingLabel.numberOfLines = 0;
        loadingLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:loadingLabel];
    }
    
    return self;
}


@end
