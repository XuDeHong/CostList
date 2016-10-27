//
//  SlideMenuViewController.m
//  CostList
//
//  Created by 许德鸿 on 16/8/31.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "SlideMenuViewController.h"
#import "SlideNavigationViewController.h"


@interface SlideMenuViewController ()

@property (weak,nonatomic) SlideNavigationViewController *slideNavigationController;

@end

@implementation SlideMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(SlideNavigationViewController *)slideNavigationController
{
    if(!_slideNavigationController)
    {
        _slideNavigationController = (SlideNavigationViewController *)self.navigationController;
    }
    return _slideNavigationController;
}

- (IBAction)cancelBtnDidClick:(id)sender {
    //由右向左滑走
    self.slideNavigationController.isVisible = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.navigationController.view.x = 0 - SCREEN_WIDTH;
    } completion:^(BOOL finished){
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];
}

-(void)confirmDeleteAllData
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"注意", @"注意") message:NSLocalizedString(@"确定要清空所有数据吗？（数据清空后不可恢复）",@"确定要清空所有数据吗？（数据清空后不可恢复）") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureBtn = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", @"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
        
    }];
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", @"取消") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
    }];
    [controller addAction:sureBtn];
    [controller addAction:cancelBtn];
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark Table View Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && indexPath.row == 2)    //清空数据
    {
        [self confirmDeleteAllData];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return tableView.rowHeight;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN; //没有footer
}
@end
