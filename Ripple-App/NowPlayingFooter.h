//
//  NowPlayingFooter.h
//  Ripple-App
//
//  Created by William O'Connor on 7/1/15.
//  Copyright (c) 2015 Ripple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerViewController.h"

@protocol NowPlayingFooterDelegate <NSObject>

- (void) footerPressed;

@end

@interface NowPlayingFooter : UIView

@property (strong, nonatomic) UIImageView* albumView;
@property (strong, nonatomic) UIButton* songLabel;
- (id) initWithSongName:(NSString*)song andAlbumCover:(UIImage*)albumCover;
@property (nonatomic) id <NowPlayingFooterDelegate> delegate;
@property (strong, nonatomic) PlayerViewController* playerVC;
@property (strong, nonatomic) NSDictionary* song;

-(void) updateInfo:(NSDictionary*)info;

@end
