//
//  NowPlayingFooter.h
//  Ripple-App
//
//  Created by William O'Connor on 7/1/15.
//  Copyright (c) 2015 Gooey Dee Bee. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NowPlayingFooterDelegate <NSObject>

- (void) footerPressed;

@end

@interface NowPlayingFooter : UIView

@property (strong, nonatomic) UIImageView* albumView;
@property (strong, nonatomic) UIButton* songLabel;
- (id) initWithSongName:(NSString*)song andAlbumCover:(UIImage*)albumCover;
@property (nonatomic) id <NowPlayingFooterDelegate> delegate;

-(void) updateInfo:(NSDictionary*)info;

@end
