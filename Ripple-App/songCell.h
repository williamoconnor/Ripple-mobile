//
//  songCell.h
//  Ripple-App
//
//  Created by William O'Connor on 4/22/15.
//  Copyright (c) 2015 Gooey Dee Bee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol rippleSongCellDelegate <NSObject>

- (void) drop:(NSNumber*) song_id;

@end

@interface songCell: UITableViewCell

@property (strong, nonatomic) NSNumber* track;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *artistLabel;
@property (strong, nonatomic) UIImageView *albumCover;
@property (weak, nonatomic) id <rippleSongCellDelegate> delegate;
@property (strong, nonatomic) UIButton* dropButton;


-(void) setData: (NSDictionary*)track;
-(void) createDropButton;
-(void) hideDropButton;

@end
