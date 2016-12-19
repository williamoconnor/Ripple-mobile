//
//  dropFeedTableView.m
//  Ripple-App
//
//  Created by William O'Connor on 9/6/15.
//  Copyright (c) 2015 Ripple. All rights reserved.
//

#import "DropFeedTableView.h"

@implementation DropFeedTableView

-(id)initWithFrame:(CGRect)frame andTracks:(NSMutableArray *)tracks andAlbumCovers:(NSMutableArray *)albumCovers
{
    self = [super initWithFrame:frame];
    
    if (self) {
        // customization
        self.tracks = tracks;
        self.albumCovers = albumCovers;
        
    }
    
    return self;
}

@end
