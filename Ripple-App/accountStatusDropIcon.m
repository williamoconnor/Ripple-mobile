//
//  accountStatusDropIcon.m
//  Ripple-App
//
//  Created by William O'Connor on 12/11/16.
//  Copyright © 2016 Ripple, LLC. All rights reserved.
//

#import "accountStatusDropIcon.h"

@implementation accountStatusDropIcon

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
        // background gradient
        
        // imageview
        UIImageView* cutout = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        cutout.image = [UIImage imageNamed:@"account-header-bg.png"];
        [self addSubview:cutout];
    }
    
    return self;
}

@end
