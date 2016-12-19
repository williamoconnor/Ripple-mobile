//
//  songCell.m
//  Ripple-App
//
//  Created by William O'Connor on 4/22/15.
//  Copyright (c) 2015 Ripple. All rights reserved.
//

#import "songCell.h"
#import "Colors.h"
#import "Rankings.h"
#import "LoadingScreen.h"

@interface songCell()

@property (strong, nonatomic) NSDictionary* screen;

@end

@implementation songCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // Initialization code
        
        self.screen = [[NSUserDefaults standardUserDefaults] objectForKey:@"screen"];
        
        //set the height of the selected cell in the tableview
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(99.0, 10.0, [self.screen[@"width"] doubleValue]*0.58, 60.0)];
        // self.titleLabel.backgroundColor = [UIColor blackColor];
        self.artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(101.0, 75.0, [self.screen[@"width"] doubleValue]*0.58, 15.0)];
//        self.artistLabel.backgroundColor = [UIColor blueColor];
        self.albumCover = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, 80.0, 80.0)];
//        [self.albumCover.layer setBorderColor: [cPrimaryPink CGColor]];
//        [self.albumCover.layer setBorderWidth: 1.0];
//        [self.albumCover.layer setCornerRadius:2.0];
        self.titleLabel.numberOfLines = 0;
        self.artistLabel.numberOfLines = 0;

        self.titleLabel.font = [UIFont fontWithName:@"Avenir Next" size:17.0];
        self.artistLabel.font = [UIFont fontWithName:@"Avenir Next" size:13.0];
        self.titleLabel.textColor = cPrimaryNavy;
        self.artistLabel.textColor = cPrimaryNavy;
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.artistLabel];
        [self.contentView addSubview:self.albumCover];
        
//        self.backgroundColor = [UIColor colorWithRed:0x1F/255.0 green:0x32/255.0 blue:0x4D/255.0 alpha:1.0];
//        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"email"] length] > 3) {
//            [self dropButton];
//        }
        
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:NO];
//    self.titleLabel.textColor = cPrimaryPink;
//    self.artistLabel.textColor = cPrimaryPink;
}

-(void) setData:(NSDictionary *)track andType:(NSString*)type
{    
    if (track) {
        self.type = type;
        self.titleLabel.text = track[@"name"];
        self.artistLabel.text = track[@"artist"];
        self.dropperRank = track[@"dropper_rank"];
        
        self.albumCover.contentMode = UIViewContentModeScaleAspectFit;
        self.track = track;
        self.trackId = track[@"soundcloud_track_id"];
    }
}

- (void) createDropButton
{
    self.dropButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.dropButton.frame = CGRectMake([self.screen[@"width"] floatValue] - 45.0, 30.0, 40.0, 40.0);
    [self.dropButton addTarget:self
                     action:@selector(drop)
           forControlEvents:UIControlEventTouchUpInside];
    
    NSString* imageName = [NSString stringWithFormat:@"%@-drop-outline-small.png", [Rankings getRankingToColorString:[self.dropperRank intValue]]];
    [self.dropButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    
    //self.titleLabel.frame = CGRectMake(120.0, 10.0, [self.screen[@"width"] doubleValue]*0.48, 60.0);
    [self.contentView addSubview:self.dropButton];
}

-(void) drop
{
    NSLog(@"Track: %@", self.track);
    [LoadingScreen showDroppingScreen];
    double delayInSeconds = 0.01;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.delegate drop: self.type andTrack:self.track];
    });
}

-(void) hideDropButton
{
    //[self.dropButton removeFromSuperview];
    for (UIView* subview in [self.contentView subviews]) {
        if ([subview isKindOfClass:[UIButton class]]) {
            [subview removeFromSuperview];
        }
    }
}


@end
