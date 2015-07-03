//
//  songCell.m
//  Ripple-App
//
//  Created by William O'Connor on 4/22/15.
//  Copyright (c) 2015 Gooey Dee Bee. All rights reserved.
//

#import "songCell.h"

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
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(120.0, 10.0, [self.screen[@"width"] doubleValue]*0.58, 60.0)];
        self.artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(120.0, 75.0, [self.screen[@"width"] doubleValue]*0.58, 15.0)];
        self.albumCover = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 100.0)];
        self.titleLabel.numberOfLines = 0;
        self.artistLabel.numberOfLines = 0;

        self.titleLabel.font = [UIFont fontWithName:@"Poiret One" size:14];
        self.artistLabel.font = [UIFont fontWithName:@"Poiret One" size:12];
        self.titleLabel.textColor = [UIColor colorWithRed:0xE0/255.0 green:0xF5/255.0 blue:0xFF/255.0 alpha:1.0];
        self.artistLabel.textColor = [UIColor colorWithRed:0xBB/255.0 green:0xDF/255.0 blue:0xF0/255.0 alpha:1.0];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.artistLabel];
        [self.contentView addSubview:self.albumCover];
        
//        self.backgroundColor = [UIColor colorWithRed:0x1F/255.0 green:0x32/255.0 blue:0x4D/255.0 alpha:1.0];
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"email"] length] > 3) {
            [self dropButton];
        }
        
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:NO];
    self.backgroundColor = [UIColor colorWithRed:0x59/255.0 green:0x69/255.0 blue:0x80/255.0 alpha:1.0];
}

-(void) setData:(NSDictionary *)track
{    
    if (track) {
        UIImage* albumCoverImage;
        self.titleLabel.text = track[@"title"];
        if (![track[@"label_name"] isEqual:[NSNull null]] && [track[@"label_name"] length] > 0){
            self.artistLabel.text = track[@"label_name"];
        }
        else {
            self.artistLabel.text = track[@"user"][@"permalink"];
        }
        
        if (![track[@"artwork_url"] isEqual:[NSNull null]] && [track[@"artwork_url"] length] > 0){
            albumCoverImage = [UIImage imageWithData:
                            [NSData dataWithContentsOfURL:
                             [NSURL URLWithString: track[@"artwork_url"]]]];
        }
        else {
            albumCoverImage = [UIImage imageNamed:@"NowPlaying.png"];
        }
        
        self.albumCover.image = albumCoverImage;
        self.track = track[@"id"];
    }
}

- (void) createDropButton
{
    self.dropButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.dropButton.frame = CGRectMake([self.screen[@"width"] floatValue] - 45.0, 30.0, 40.0, 40.0);
    [self.dropButton addTarget:self
                     action:@selector(drop)
           forControlEvents:UIControlEventTouchUpInside];
    [self.dropButton setImage:[UIImage imageNamed:@"dropItIcon.png"] forState:UIControlStateNormal];
    
    self.titleLabel.frame = CGRectMake(120.0, 10.0, [self.screen[@"width"] doubleValue]*0.48, 60.0);
    [self.contentView addSubview:self.dropButton];
}

-(void) drop
{
    NSLog(@"Track: %@", self.track);
    [self.delegate drop: self.track];
}

-(void) hideDropButton
{
    [self.dropButton removeFromSuperview];
    NSLog(@"%@",[self.contentView subviews]);
    NSLog(@"Called it");
}


@end
