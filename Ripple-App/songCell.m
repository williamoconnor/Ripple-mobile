//
//  songCell.m
//  Ripple-App
//
//  Created by William O'Connor on 4/22/15.
//  Copyright (c) 2015 Gooey Dee Bee. All rights reserved.
//

#import "songCell.h"

@interface songCell()

@end

@implementation songCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // Initialization code
        
        //set the height of the selected cell in the tableview
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(120.0, 10.0, 220.0, 60.0)];
        self.artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(120.0, 75.0, 220.0, 15.0)];
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
        
        self.backgroundColor = [UIColor colorWithRed:0x19/255.0 green:0x66/255.0 blue:0xA8/255.0 alpha:1.0];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:NO];
}

-(void) setData:(NSDictionary *)track
{
    self.titleLabel.text = track[@"title"];
    if ([track[@"label_name"] length] > 0){
        self.artistLabel.text = track[@"label_name"];
    }
    else {
        self.artistLabel.text = track[@"user"][@"permalink"];
    }
    
    UIImage* albumCoverImage = [UIImage imageWithData:
                        [NSData dataWithContentsOfURL:
                         [NSURL URLWithString: track[@"artwork_url"]]]];
    
    self.albumCover.image = albumCoverImage;
}


@end
