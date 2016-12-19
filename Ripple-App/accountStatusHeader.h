//
//  accountStatusHeader.h
//  Ripple-App
//
//  Created by William O'Connor on 12/11/16.
//  Copyright © 2016 Ripple, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "accountStatusDropIcon.h"

@protocol statusHeaderDelegate <NSObject>

-(void)logout;
-(void)back;

@end

@interface accountStatusHeader : UIView

@property (strong, nonatomic)accountStatusDropIcon* dropView;
@property (strong, nonatomic)NSString* email;

@property (weak, nonatomic) id<statusHeaderDelegate> delegate;

@property (strong, nonatomic)UIButton* backButton;
@property (strong, nonatomic)UIButton* logoutButton;

-(id)initWithWidth:(float)width andRank:(int)rank andPoints:(float)points;

@end
