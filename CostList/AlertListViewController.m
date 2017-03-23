//
//  AlertSettingViewController.m
//  CostList
//
//  Created by 许德鸿 on 2017/3/19.
//  Copyright © 2017年 XuDeHong. All rights reserved.
//

#import "AlertListViewController.h"
#import "NotificationModel.h"
#import "AlertEditTableViewController.h"
#import <UserNotifications/UserNotifications.h>

static NSString* const alertCellIdentifier = @"AlertCell";  //定义全局静态常量

@interface AlertListViewController () <UITableViewDelegate,UITableViewDataSource,AlertEditTableViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic,strong) NSMutableArray *modelArray;

@end

@implementation AlertListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //初始化通知模型数组
    NSFileManager *manager = [[NSFileManager alloc] init];
    if([manager fileExistsAtPath:[self notificationListFilePath]])
    {//如果已有通知列表文件，则初始化
        self.modelArray = [NSKeyedUnarchiver unarchiveObjectWithFile:[self notificationListFilePath]];
        [self.myTableView reloadData];
        //遍历通知列表看是否设置，如果没设置则设置一遍（用于从网络同步数据下来）
        for(NotificationModel *model in self.modelArray)
        {
            [self setNotificationForModel:model];
        }
    }
    else
    {//否则新建数组
        self.modelArray = [NSMutableArray arrayWithCapacity:10];
    }
    
    //创建通知Action
    UNNotificationAction *addItemAction = [UNNotificationAction actionWithIdentifier:@"addItemAction" title:@"添加账目" options:UNNotificationActionOptionForeground];
    //创建Category
    UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:@"NotificationCategory" actions:@[addItemAction] intentIdentifiers:@[] options:UNNotificationCategoryOptionNone];
    //将Category注册到通知中心
    [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:[NSSet setWithArray:@[category]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *)documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths lastObject];
    return documentsDirectory;
}

-(NSString *)notificationListFilePath
{
    return [[self documentsDirectory] stringByAppendingPathComponent:@"NotificationList.data"];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"EditNotification"])
    {
        AlertEditTableViewController *controller = (AlertEditTableViewController *)segue.destinationViewController;
        controller.delegate = self;
        controller.title = NSLocalizedString(@"编辑提醒", @"编辑提醒");
        
        NSIndexPath *indexPath = [self.myTableView indexPathForCell:sender];
        controller.notificationModel = (NotificationModel *)self.modelArray[indexPath.row];
    }
    else if([segue.identifier isEqualToString:@"AddNotification"])
    {
        AlertEditTableViewController *controller = (AlertEditTableViewController *)segue.destinationViewController;
        controller.delegate = self;
    }
}

-(UNCalendarNotificationTrigger *)getNotificationTriggerFromModel:(NotificationModel *)model
{
    int timeArray[5];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    //根据通知的设置获取时间
    NSDate *date = [formatter dateFromString:model.alertTime];
    //获取年份
    [formatter setDateFormat:@"yyyy"];
    NSString *year = [formatter stringFromDate:date];
    timeArray[0] = [year intValue];
    //获取月份
    [formatter setDateFormat:@"MM"];
    NSString *month = [formatter stringFromDate:date];
    timeArray[1] = [month intValue];
    //获取日期
    [formatter setDateFormat:@"dd"];
    NSString *day = [formatter stringFromDate:date];
    timeArray[2] = [day intValue];
    //获取小时
    [formatter setDateFormat:@"HH"];
    NSString *hour = [formatter stringFromDate:date];
    timeArray[3] = [hour intValue];
    //获取分钟
    [formatter setDateFormat:@"mm"];
    NSString *minue = [formatter stringFromDate:date];
    timeArray[4] = [minue intValue];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    BOOL isRepeats = YES;
    //根据提醒周期进行不同的设置
    if([model.alertCycle isEqualToString:@"提醒一次"])
    {
        isRepeats = NO;
        components.year = timeArray[0];
        components.month = timeArray[1];
        components.day = timeArray[2];
        components.hour = timeArray[3];
        components.minute = timeArray[4];
    }
    else if([model.alertCycle isEqualToString:@"每日"])
    {
        components.hour = timeArray[3];
        components.minute = timeArray[4];
    }
    else if([model.alertCycle isEqualToString:@"每周"])
    {
        NSDateComponents *tempCom = [[NSDateComponents alloc] init];
        [tempCom setYear:timeArray[0]];
        [tempCom setMonth:timeArray[1]];
        [tempCom setDay:timeArray[2]];
        //通过上面的临时对象计算出星期几
        components.weekday = [tempCom weekday];
        components.hour = timeArray[3];
        components.minute = timeArray[4];
        
    }
    else if([model.alertCycle isEqualToString:@"每月"])
    {
        components.day = timeArray[2];
        components.hour = timeArray[3];
        components.minute = timeArray[4];
    }
    else if([model.alertCycle isEqualToString:@"每年"])
    {
        components.month = timeArray[1];
        components.day = timeArray[2];
        components.hour = timeArray[3];
        components.minute = timeArray[4];
    }
    
    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:isRepeats];
    return trigger;
}

-(void)setNotificationForModel:(NotificationModel *)model
{
    //第一步，设置通知内容
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = @"记账提醒";
    content.body = model.alertTitle;
    content.categoryIdentifier = @"NotificationCategory";
    content.sound = [UNNotificationSound defaultSound];
    content.badge = @1;
    //第二步，设置触发时间
    UNCalendarNotificationTrigger *trigger = [self getNotificationTriggerFromModel:model];
    //第三步，定义一个标识符标识通知
    NSString *requestIdentifier = model.alertID;
    //第四步，根据内容，触发时间，标识符创建一个通知request，并添加到通知中心
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifier content:content trigger:trigger];
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {}];

}

#pragma mark - AlertEditTableViewController Delegate
-(void)alertEditTableViewController:(AlertEditTableViewController *)controller addNotification:(NotificationModel *)model
{
    //添加通知模型
    [self.modelArray addObject:model];
    //归档保存
    [NSKeyedArchiver archiveRootObject:self.modelArray toFile:[self notificationListFilePath]];
    [self.myTableView reloadData];
    //添加通知
    [self setNotificationForModel:model];
}

-(void)alertEditTableViewController:(AlertEditTableViewController *)controller modifiedNotification:(NotificationModel *)model
{
    //修改通知模型
    //归档保存
    [NSKeyedArchiver archiveRootObject:self.modelArray toFile:[self notificationListFilePath]];
    [self.myTableView reloadData];
    //修改通知，在ID不变的情况下重新添加通知即可
    [self setNotificationForModel:model];
}

#pragma mark - Table View DataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.modelArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:alertCellIdentifier];
    NotificationModel *model = self.modelArray[indexPath.row];
    UILabel *titleLbl = (UILabel *)[cell viewWithTag:2000];
    titleLbl.text = model.alertTitle;
    UILabel *timeLbl = (UILabel *)[cell viewWithTag:2001];
    timeLbl.text = model.alertTime;
    UILabel *cycleLbl = (UILabel *)[cell viewWithTag:2002];
    cycleLbl.text = model.alertCycle;
    return cell;
}

#pragma mark Table View Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        //删除通知
        NotificationModel *model = self.modelArray[indexPath.row];
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center removePendingNotificationRequestsWithIdentifiers:@[model.alertID]];
        [center removeDeliveredNotificationsWithIdentifiers:@[model.alertID]];
        
        //删除通知模型
        [self.modelArray removeObject:model];
        //归档保存
        [NSKeyedArchiver archiveRootObject:self.modelArray toFile:[self notificationListFilePath]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
