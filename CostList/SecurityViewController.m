//
//  SecurityViewController.m
//  CostList
//
//  Created by 许德鸿 on 2016/10/28.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "SecurityViewController.h"
#import "CLLockVC.h"
#import <LocalAuthentication/LocalAuthentication.h>

#define IS_IOS_8 (NSFoundationVersionNumber>=NSFoundationVersionNumber_iOS_8_0? YES : NO)
#define IOS_VERSION_10 (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_9_x_Max)?(YES):(NO)


@interface SecurityViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *gestureSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *fingerprintSwitch;

@end

@implementation SecurityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.tableView.tableFooterView.y, SCREEN_WIDTH, 50)];
    UILabel *label = [[UILabel alloc] init];
    label.text = @"两种安全保护方式只能选择其中一种";
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor grayColor];
    [label sizeToFit];
    label.y = self.tableView.tableFooterView.y;
    label.centerX = self.view.centerX;
    [footerView addSubview:label];
    self.tableView.tableFooterView = footerView;
    
    //初始化两个开关按钮
    BOOL gestureLockIsOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"gestureLockIsOn"];
    BOOL fingerprintLockIsOn = [[NSUserDefaults standardUserDefaults
                                 ] boolForKey:@"fingerprintLockIsOn"];
    if(gestureLockIsOn)
    {
        self.gestureSwitch.on = YES;
        [self showChangeGestureLockCell];
    }
    else
    {
        self.gestureSwitch.on = NO;
        [self hideChangeGestureLockCell];
    }
    if(fingerprintLockIsOn)
    {
        self.fingerprintSwitch.on = YES;
    }
    else
    {
        self.fingerprintSwitch.on = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)gestureSwitchDidClick:(UISwitch *)sender {
    if(self.fingerprintSwitch.on == NO)
    {
        if(sender.on == YES)    //开启手势密码
        {
            sender.on = NO; //若不设置密码直接关闭时，则开关为OFF
            [CLLockVC showSettingLockVCInVC:self successBlock:^(CLLockVC *lockVC, NSString *pwd) {
                [lockVC dismiss:0.5f];
                BOOL hasPwd = [CLLockVC hasPwd];
                if(hasPwd)
                {
                    self.gestureSwitch.on = YES; //若成功设置密码，则开关为ON
                    [self showChangeGestureLockCell];
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"gestureLockIsOn"];
                }
                else
                {
                    self.gestureSwitch.on = NO;  //防御性代码，若没有设置密码，则开关为OFF
                    [self hideChangeGestureLockCell];
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"gestureLockIsOn"];
                }
            }];
        }
        else    //关闭手势密码
        {
            [self hideChangeGestureLockCell];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"gestureLockIsOn"];
        }
    }
    else    //若指纹解锁有开启，则不可开启手势密码
    {
        sender.on = NO;
    }
}

-(void)showChangeGestureLockCell    //显示修改手势密码的cell
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if(cell == nil)
    {
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

-(void)hideChangeGestureLockCell    //隐藏修改手势密码的cell
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if(cell != nil)
    {
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

- (IBAction)fingerprintSwitchDidClick:(UISwitch *)sender {
    if(self.gestureSwitch.on == NO)
    {
        if(sender.on == YES)    //开启指纹识别
        {
            sender.on = NO;
            if([self checkDeviceWhetherHasTouchID])
            {
                if((IS_IOS_8) || (IOS_VERSION_10))
                {
                    sender.on = YES;
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"fingerprintLockIsOn"];
                }
                else
                {
                    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"提示" message:@"系统版本过低，请升级版本后重试" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
                    [controller addAction:action];
                    [self presentViewController:controller animated:YES completion:nil];
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"fingerprintLockIsOn"];
                }
            }
            else    //设备不支持指纹识别
            {
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"fingerprintLockIsOn"];
            }

        }
        else    //关闭指纹识别
        {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"fingerprintLockIsOn"];
        }
    }
    else    //若手势密码有开启，则不可开启指纹解锁
    {
        sender.on = NO;
    }
}

-(BOOL)checkDeviceWhetherHasTouchID
{
    //创建LAContext
    LAContext* context = [[LAContext alloc] init];
    NSError* error = nil;
    
    //使用canEvaluatePolicy 判断设备是否支持TouchID
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error])
    {
        //支持指纹验证
        return YES;
    }
    else
    {
        NSString *text = nil;
        //不支持指纹识别，LOG出错误详情
        switch (error.code)
        {
            case LAErrorTouchIDNotEnrolled:
            {
                text = @"未录入TouchID信息，请录入后重试";//NSLog(@"TouchID is not enrolled");
                break;
            }
            case LAErrorPasscodeNotSet:
            {
                text = @"未设置TouchID信息，请设置后重试";//NSLog(@"A passcode has not been set");
                break;
            }
            default:
            {
                text = @"TouchID不可用，设备不支持或未打开，若设备支持则打开后重试";//NSLog(@"TouchID not available");
                break;
            }
        }
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"提示" message:text preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [controller addAction:action];
        [self presentViewController:controller animated:YES completion:nil];
        NSLog(@"%@",error.localizedDescription);
        return NO;
    }
}


#pragma mark - TableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 && (self.gestureSwitch.on == YES)) //添加修改手势密码cell
    {
        return 2;
    }
    else
    {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 1)   //添加修改手势密码cell
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChangeGestureLockCell"];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ChangeGestureLockCell"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = @"修改手势密码";
            cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        }
        return cell;
    } else {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

#pragma mark - TableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && indexPath.row == 1)    //修改手势密码cell那一行的高度
    {
        return tableView.rowHeight;
    }
    else
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

// Need to override this or the app crashes
- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 1)
    {
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:0 inSection:indexPath.section];
        return [super tableView:tableView indentationLevelForRowAtIndexPath:newIndexPath];
    }
    else
    {
        return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 1)   //修改手势密码cell可点击
    {
        return indexPath;
    }
    else
    {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && indexPath.row == 1)   //修改手势密码cell点击处理
    {
        [CLLockVC showModifyLockVCInVC:self successBlock:^(CLLockVC *lockVC, NSString *pwd) {
            [lockVC dismiss:.5f];
        }];
    }
}
@end
