//
//  NowPlayingFooter.m
//  Ripple-App
//
//  Created by William O'Connor on 7/1/15.
//  Copyright (c) 2015 Gooey Dee Bee. All rights reserved.
//

#import "NowPlayingFooter.h"

@implementation NowPlayingFooter

- (id) initWithSongName:(NSString*)song andAlbumCover:(UIImage*)albumCover
{
    NSLog(@"%@", song);
    self = [super init];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    NSNumber *height = [[NSNumber alloc] initWithDouble:screenHeight];
    NSNumber *width = [[NSNumber alloc] initWithDouble:screenWidth];
    
    if (self) {
        //do shit
        self.frame = CGRectMake(0.0, [height floatValue]-60.0, [width floatValue], 60.0);
        self.backgroundColor = [UIColor colorWithRed:0x59/255.0 green:0x69/255.0 blue:0x80/255.0 alpha:1.0];
        self.songLabel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.songLabel.frame = CGRectMake(60.0, 20.0, [width floatValue] - 60.0, 20.0);
        [self.songLabel setTitle:song forState:UIControlStateNormal];
        self.songLabel.titleLabel.font = [UIFont fontWithName:@"Poiret One" size:14];
        [self.songLabel setTintColor:[UIColor whiteColor]];
        self.songLabel.backgroundColor = [UIColor colorWithWhite:255.0 alpha:0.0];
        self.songLabel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.songLabel addTarget:self action:@selector(footerPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.songLabel];
        
        self.albumView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, 40.0, 40.0)];
        self.albumView.image = albumCover;
        [self addSubview:self.albumView];
    }
    return self;
}

-(void) footerPressed
{
    [self.delegate footerPressed];
}

-(void) updateInfo:(NSDictionary *)info
{
    [self.songLabel setTitle:info[@"song"] forState:UIControlStateNormal];
    self.albumView.image = info[@"album"];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
