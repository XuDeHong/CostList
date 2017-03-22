//
//  AlertEditTableViewController.m
//  CostList
//
//  Created by 许德鸿 on 2017/3/19.
//  Copyright © 2017年 XuDeHong. All rights reserved.
//

#import "AlertEditTableViewController.h"
#import "EditAlertTitleViewController.h"
#import "MyTimePickerController.h"
#import "CyclePickerViewController.h"
#import "NotificationModel.h"
#import <KVNProgress/KVNProgress.h>

@interface AlertEditTableViewController () <EditAlertTitleViewControllerDelegate, MyTimePickerControllerDelegate,CyclePickerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic,weak) IBOutlet UILabel *timeLabel;
@property (nonatomic,weak) IBOutlet UILabel *cycleLabel;
@property (nonatomic,strong) EditAlertTitleViewController *editAlertTitleViewController;
@property (nonatomic,strong) MyTimePickerController *timePickerController;
@property (nonatomic,strong) CyclePickerViewController *cyclePickerViewController;

@end

@implementation AlertEditTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //根据通知模型初始化
    if(self.notificationModel == nil)
    {
        self.titleLabel.text = nil;
        self.timeLabel.text = nil;
        self.cycleLabel.text = nil;
    }
    else
    {
        self.titleLabel.text = self.notificationModel.alertTitle;
        self.timeLabel.text = self.notificationModel.alertTime;
        self.cycleLabel.text = self.notificationModel.alertCycle;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sureBtnClick:(id)sender{
    [self.view endEditing:YES]; //键盘消失
    if([self textDataWhetherInput]) //测试数据是否输入
    {
        if(self.notificationModel == nil)
        {
            //调用代理实现的方法，添加新通知
            [self.delegate alertEditTableViewController:self addNotification:[self getDataToSave]];
        }
        else
        {
            //修改已有的通知
            [self.delegate alertEditTableViewController:self modifiedNotification:[self getDataToSave]];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(BOOL)textDataWhetherInput
{
    KVNProgressConfiguration *configuration = [[KVNProgressConfiguration alloc] init];
    configuration.circleSize = 60.0f;   //设置success图标大小
    configuration.errorColor = [UIColor redColor];   //设置success图标颜色
    configuration.minimumErrorDisplayTime = 0.8f; //设置动画时间
    configuration.statusFont = [UIFont boldSystemFontOfSize:15.0]; //设置字体大小
    configuration.backgroundFillColor = [UIColor whiteColor];   //设置背景颜色
    configuration.backgroundType = KVNProgressBackgroundTypeSolid;  //设置背景类型
    [KVNProgress setConfiguration:configuration];
    
    if((self.titleLabel.text == nil) || ([self.titleLabel.text isEqualToString:@""]))
    {
        [KVNProgress showErrorWithStatus:@"请输入内容" completion:nil];
        return NO;
    }
    else if((self.timeLabel.text == nil) || ([self.timeLabel.text isEqualToString:@""]))
    {
        [KVNProgress showErrorWithStatus:@"请选择时间" completion:nil];
        return NO;
    }
    else if((self.cycleLabel.text == nil) || ([self.cycleLabel.text isEqualToString:@""]))
    {
        [KVNProgress showErrorWithStatus:@"请选择周期" completion:nil];
        return NO;
    }
    else
        return YES;
}

-(NotificationModel *)getDataToSave
{
    NotificationModel *model = nil;
    if(self.notificationModel != nil)
    {
        model = self.notificationModel;
    }
    else
    {
        model = [[NotificationModel alloc] init];
        model.alertID = [NotificationModel nextNotificationID];
    }
    
    model.alertTitle = self.titleLabel.text;
    model.alertTime = self.timeLabel.text;
    model.alertCycle = self.cycleLabel.text;

    return model;
}

#pragma mark - About edit title methods
-(EditAlertTitleViewController *)editAlertTitleViewController
{
    if(!_editAlertTitleViewController)
    {
        _editAlertTitleViewController = [[EditAlertTitleViewController alloc] initWithNibName:@"EditAlertTitleViewController" bundle:nil];
    }
    return _editAlertTitleViewController;
}

-(void)showEditAlertTitleView
{
    self.editAlertTitleViewController.currentTitle = self.titleLabel.text;
    //设置代理
    self.editAlertTitleViewController.delegate = self;
    //显示编辑视图
    [self presentViewController:self.editAlertTitleViewController animated:YES completion:nil];
}

#pragma mark EditAlertTitleViewController Delegate
-(void)editAlertTitleViewController:(EditAlertTitleViewController *)controller editedAlertTitle:(NSString *)alertTitle
{
    self.titleLabel.text = alertTitle;
}

#pragma mark - About choose time methods
-(MyTimePickerController *)timePickerController
{
    if(!_timePickerController)
    {
        _timePickerController = [[MyTimePickerController alloc] initWithNibName:@"MyTimePickerController" bundle:nil];
    }
    return _timePickerController;
}

-(void)showTimePickerView
{
    //设置时间选择器的时间为标签中显示的时间
    self.timePickerController.currentTime = self.timeLabel.text;
    //设置代理
    self.timePickerController.delegate = self;
    //显示选择日期
    [self presentViewController:self.timePickerController animated:YES completion:nil];
}

#pragma mark MyTimePickerController Delegate
-(void)myTimePickerController:(MyTimePickerController *)controller didChooseTime:(NSString *)time
{
    //更新时间标签
    self.timeLabel.text = time;
}

#pragma mark - About choose cycle methods
-(CyclePickerViewController *)cyclePickerViewController
{
    if(!_cyclePickerViewController)
    {
        _cyclePickerViewController = [[CyclePickerViewController alloc] initWithNibName:@"CyclePickerViewController" bundle:nil];
    }
    return _cyclePickerViewController;
}

-(void)showCyclePickerView
{
    self.cyclePickerViewController.currentCycle = self.cycleLabel.text;
    self.cyclePickerViewController.delegate = self;
    [self presentViewController:self.cyclePickerViewController animated:YES completion:nil];
}

#pragma mark CyclePickerViewController Delegate
-(void)cyclePickerViewController:(CyclePickerViewController *)controller didChooseCycle:(NSString *)cycle
{
    self.cycleLabel.text = cycle;
}

#pragma mark - TableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && indexPath.row == 0)
    {   //输入提醒内容
        [self showEditAlertTitleView];
    }
    else if(indexPath.section == 0 && indexPath.row == 1)
    {   //选择提醒时间
        [self showTimePickerView];
        
    }
    else if(indexPath.section == 0 && indexPath.row == 2)
    {   //选择提醒周期
        [self showCyclePickerView];
        
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
