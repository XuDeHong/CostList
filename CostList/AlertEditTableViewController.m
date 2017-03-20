//
//  AlertEditTableViewController.m
//  CostList
//
//  Created by 许德鸿 on 2017/3/19.
//  Copyright © 2017年 XuDeHong. All rights reserved.
//

#import "AlertEditTableViewController.h"
#import "MyTimePickerController.h"
#import "CyclePickerViewController.h"
#import "NotificationModel.h"

@interface AlertEditTableViewController () <MyTimePickerControllerDelegate,CyclePickerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *alertTitleTextField;
@property (nonatomic,weak) IBOutlet UILabel *timeLabel;
@property (nonatomic,weak) IBOutlet UILabel *cycleLabel;
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
        self.timeLabel.text = nil;
        self.cycleLabel.text = nil;
    }
    else
    {
        self.alertTitleTextField.text = self.notificationModel.alertTitle;
        self.timeLabel.text = self.notificationModel.alertTime;
        self.cycleLabel.text = self.notificationModel.alertCycle;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - About choose time method
-(void)getCurrentDate
{
    //获取当前时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *now = [NSDate date];
    self.timeLabel.text = [formatter stringFromDate:now];
}

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
    self.timePickerController.currentDate = self.timeLabel.text;
    //设置代理
    self.timePickerController.delegate = self;
    //显示选择日期
    [self presentViewController:self.timePickerController animated:YES completion:nil];
}

#pragma mark MyTimePickerController Delegate
-(void)myTimePickerController:(MyTimePickerController *)controller didChooseDate:(NSString *)date
{
    //更新时间标签
    self.timeLabel.text = date;
}

#pragma mark - About choose cycle method
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
        [self.alertTitleTextField becomeFirstResponder];
    }
    else if(indexPath.section == 0 && indexPath.row == 1)
    {   //选择提醒时间
        [self.alertTitleTextField resignFirstResponder];
        [self showTimePickerView];
        
    }
    else if(indexPath.section == 0 && indexPath.row == 2)
    {   //选择提醒周期
        [self.alertTitleTextField resignFirstResponder];
        [self showCyclePickerView];
        
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
