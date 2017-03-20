//
//  AlertSettingViewController.m
//  CostList
//
//  Created by 许德鸿 on 2017/3/19.
//  Copyright © 2017年 XuDeHong. All rights reserved.
//

#import "AlertListViewController.h"
#import "NotificationModel.h"

static NSString* const alertCellIdentifier = @"AlertCell";  //定义全局静态常量

@interface AlertListViewController () <UITableViewDelegate,UITableViewDataSource>

@end

@implementation AlertListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View DataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:alertCellIdentifier];
    UILabel *titleLbl = (UILabel *)[cell viewWithTag:2000];
    titleLbl.text = @"1";
    UILabel *timeLbl = (UILabel *)[cell viewWithTag:2001];
    timeLbl.text = @"2";
    UILabel *cycleLbl = (UILabel *)[cell viewWithTag:2002];
    cycleLbl.text = @"3";
    return cell;
}

#pragma mark Table View Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)deleteNotification
{
    
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self deleteNotification];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
