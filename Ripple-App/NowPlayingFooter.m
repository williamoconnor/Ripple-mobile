//
//  NowPlayingFooter.m
//  Ripple-App
//
//  Created by William O'Connor on 7/1/15.
//  Copyright (c) 2015 Ripple. All rights reserved.
//

#import "NowPlayingFooter.h"
#import "Colors.h"
#import "Screen.h"

@implementation NowPlayingFooter

- (id) initWithSongName:(NSString*)song andAlbumCover:(UIImage*)albumCover
{
    NSLog(@"%@", song);
    self = [super init];
    
    if (self) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        NSNumber *height = [[NSNumber alloc] initWithDouble:screenHeight];
        NSNumber *width = [[NSNumber alloc] initWithDouble:screenWidth];
        self.height = 60.0;
        
        //do shit
        self.frame = CGRectMake(0.0, [height floatValue], [width floatValue], 60.0);
        self.backgroundColor = cLighterPrimaryPink;
        self.songLabel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.songLabel.frame = CGRectMake(60.0, 0.0, [width floatValue] - 60.0, 60.0);
        [self.songLabel setTitle:song forState:UIControlStateNormal];
        self.songLabel.titleLabel.font = [UIFont fontWithName:@"Avenir Next" size:16];
        [self.songLabel setTintColor:[UIColor whiteColor]];
        self.songLabel.backgroundColor = [UIColor colorWithWhite:255.0 alpha:0.0];
        self.songLabel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.songLabel addTarget:self action:@selector(footerPressed) forControlEvents:UIControlEventTouchUpInside];
        self.songLabel.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:self.songLabel];
        
        self.albumView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, 40.0, 40.0)];
        self.albumView.contentMode = UIViewContentModeScaleAspectFit;
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
    self.song = info;
    [self.songLabel setTitle:info[@"song"] forState:UIControlStateNormal];
    self.albumView.image = info[@"album"];
}

-(void) showUnderView:(UIView*)view atY:(float)y {
    float height = [[Screen screenDimensions][@"height"] floatValue];
    float width = [[Screen screenDimensions][@"width"] floatValue];
    [self setFrame:CGRectMake(0, height, width, self.height)];
    float footerY = y;
    
    // calculate footer frame
    CGRect newFrame = self.frame;
    if (y > 0) {
        newFrame.origin.y = y;
    }
    else {
        newFrame.origin.y = view.frame.size.height - self.frame.size.height;
        footerY = newFrame.origin.y;
    }
    
    // calculate view frame
    CGRect newViewFrame = view.frame;
    if(y > 0) {
        newViewFrame.size.height = footerY - view.frame.origin.y;
    }
    else {
        newViewFrame.size.height = footerY - view.frame.origin.y;
        // newViewFrame.size.height = view.frame.size.height - self.height;
    }
    
    [UIView animateWithDuration:0.4 animations:^{

        [self setFrame:newFrame];
        [self.songLabel addTarget:self action:@selector(footerPressed) forControlEvents:UIControlEventTouchUpInside];
    } completion:^(BOOL finished) {
        NSLog(@"hola");
        [self.songLabel addTarget:self action:@selector(footerPressed) forControlEvents:UIControlEventTouchUpInside];
        
        [view setFrame:newViewFrame];
    }];
}

-(void) hideUnderView:(UIView*)view {
    [UIView animateWithDuration:0.4 animations:^{
        CGRect newFrame = self.frame;
        newFrame.origin.y = [[Screen screenDimensions][@"height"] floatValue];
        [self setFrame:newFrame];
    } completion:^(BOOL finished) {
        CGRect newViewFrame = view.frame;
        newViewFrame.size.height = view.frame.size.height + self.height;
        [view setFrame:newViewFrame];
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
