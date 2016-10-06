//
//  songCell.h
//  Ripple-App
//
//  Created by William O'Connor on 4/22/15.
//  Copyright (c) 2015 Ripple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol rippleSongCellDelegate <NSObject>

- (void) drop:(NSString*)type andTrack:(NSDictionary*)track;

@end

@interface songCell: UITableViewCell

@property (strong, nonatomic) NSNumber* trackId;
@property (strong, nonatomic) NSDictionary* track;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *artistLabel;
@property (strong, nonatomic) UIImageView *albumCover;
@property (weak, nonatomic) id <rippleSongCellDelegate> delegate;
@property (strong, nonatomic) UIButton* dropButton;
@property (strong, nonatomic) NSString* type;


-(void) setData: (NSDictionary*)track andType:(NSString*)type;
-(void) createDropButton;
-(void) hideDropButton;

@end
