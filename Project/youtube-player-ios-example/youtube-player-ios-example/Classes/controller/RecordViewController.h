//
//  RecordViewController.h
//  youtube-player-ios-example
//
//  Created by BooBoo on 5/18/2558 BE.
//  Copyright (c) 2558 YouTube Developer Relations. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    UITableView *tableview_record;
}

@property(nonatomic, strong) IBOutlet UITableView *tableview_record;

@end
