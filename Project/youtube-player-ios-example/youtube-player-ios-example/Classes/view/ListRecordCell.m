//
//  ListRecordCell.m
//  youtube-player-ios-example
//
//  Created by BooBoo on 5/22/2558 BE.
//  Copyright (c) 2558 YouTube Developer Relations. All rights reserved.
//

#import "ListRecordCell.h"

@implementation ListRecordCell

@synthesize view_thumbnail;
@synthesize lbl_title;
@synthesize lbl_artist;
@synthesize lbl_description;
@synthesize lbl_title_detail;
@synthesize lbl_artist_detail;
@synthesize lbl_description_detail;
@synthesize btn_detail;

UIButton *btn_detail;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
