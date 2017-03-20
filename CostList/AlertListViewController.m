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
        //遍历通知列表看是否设置，如果没设置则设置一遍（用于从网络同步数据下来）
        //***
    }
    else
    {//否则新建数组
        self.modelArray = [NSMutableArray arrayWithCapacity:10];
    }
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
        controller.title = @"编辑提醒";
        
        NSIndexPath *indexPath = [self.myTableView indexPathForCell:sender];
        controller.notificationModel = (NotificationModel *)self.modelArray[indexPath.row];
    }
    else if([segue.identifier isEqualToString:@"AddNotification"])
    {
        AlertEditTableViewController *controller = (AlertEditTableViewController *)segue.destinationViewController;
        controller.delegate = self;
    }
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
    //***
}

-(void)alertEditTableViewController:(AlertEditTableViewController *)controller modifiedNotification:(NotificationModel *)model
{
    //修改通知模型
    //归档保存
    [NSKeyedArchiver archiveRootObject:self.modelArray toFile:[self notificationListFilePath]];
    [self.myTableView reloadData];
    //修改通知
    //***
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
        //删除通知模型
        [self.modelArray removeObject:self.modelArray[indexPath.row]];
        //归档保存
        [NSKeyedArchiver archiveRootObject:self.modelArray toFile:[self notificationListFilePath]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        //删除通知
        //***
    }
}

@end
