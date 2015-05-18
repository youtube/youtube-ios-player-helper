//
//  ListRecordViewController.h
//  youtube-player-ios-example
//
//  Created by BooBoo on 5/19/2558 BE.
//  Copyright (c) 2558 YouTube Developer Relations. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListRecordViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    UITableView *tableview_record;
}

@property(nonatomic, strong) IBOutlet UITableView *tableview_record;

@end
