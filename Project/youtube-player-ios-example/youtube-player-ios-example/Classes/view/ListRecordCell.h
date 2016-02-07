//
//  ListRecordCell.h
//  youtube-player-ios-example
//
//  Created by BooBoo on 5/22/2558 BE.
//  Copyright (c) 2558 YouTube Developer Relations. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListRecordCell : UITableViewCell
{
    UIImageView *view_thumbnail;
    
    UILabel *lbl_title;
    UILabel *lbl_artist;
    UILabel *lbl_description;
    
    UILabel *lbl_title_detail;
    UILabel *lbl_artist_detail;
    UILabel *lbl_description_detail;
    
    UIButton *btn_detail;
}

@property(nonatomic, strong)  IBOutlet UIImageView *view_thumbnail;
@property(nonatomic, strong)  IBOutlet UILabel *lbl_title;
@property(nonatomic, strong)  IBOutlet UILabel *lbl_artist;
@property(nonatomic, strong)  IBOutlet UILabel *lbl_description;
@property(nonatomic, strong)  IBOutlet UILabel *lbl_title_detail;
@property(nonatomic, strong)  IBOutlet UILabel *lbl_artist_detail;
@property(nonatomic, strong)  IBOutlet UILabel *lbl_description_detail;
@property(nonatomic, strong)  IBOutlet UIButton *btn_detail;

@end
