//
//  ListRecordViewController.m
//  youtube-player-ios-example
//
//  Created by BooBoo on 5/19/2558 BE.
//  Copyright (c) 2558 YouTube Developer Relations. All rights reserved.
//

#import "ListRecordViewController.h"
#import "ListRecordCell.h"
#import "RecordViewController.h"

@interface ListRecordViewController ()

@end

@implementation ListRecordViewController

@synthesize tableview_record;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableView Datasource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ListRecordCell *tableview_cell = [self.tableview_record dequeueReusableCellWithIdentifier:CELL_LIST_RECORD_ID];
    [tableview_cell.btn_detail addTarget:self action:@selector(clickBtnDetail) forControlEvents:UIControlEventTouchUpInside];
    return tableview_cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

#pragma mark - Private method
- (void) clickBtnDetail
{
    UIStoryboard *storyBoard = [self storyboard];
    RecordViewController *recordView = [storyBoard instantiateViewControllerWithIdentifier:@"RecordViewControllerID"];
    [self.navigationController pushViewController:recordView animated:YES];
}

@end
