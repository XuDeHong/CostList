//
//  SecurityViewController.m
//  CostList
//
//  Created by 许德鸿 on 2016/10/28.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "SecurityViewController.h"
#import "CLLockVC.h"

@interface SecurityViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *gestureSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *numberSwitch;
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
    label.text = @"三种安全保护方式只能选择其中一种";
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor grayColor];
    [label sizeToFit];
    label.y = self.tableView.tableFooterView.y;
    label.centerX = self.view.centerX;
    [footerView addSubview:label];
    self.tableView.tableFooterView = footerView;
    
    //初始化三个开关按钮
    BOOL gestureLockIsOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"gestureLockIsOn"];
    BOOL numberLockIsOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"numberLockIsOn"];
    BOOL fingerprintLockIsOn = [[NSUserDefaults standardUserDefaults
                                 ] boolForKey:@"fingerprintLockIsOn"];
    if(gestureLockIsOn)
    {
        self.gestureSwitch.on = YES;
    }
    else
    {
        self.gestureSwitch.on = NO;
    }
    if(numberLockIsOn)
    {
        self.numberSwitch.on = YES;
    }
    else
    {
        self.numberSwitch.on = NO;
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
    if((self.numberSwitch.on == NO) && (self.fingerprintSwitch.on == NO))
    {
        if(sender.on == YES)
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
                }
            }];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"gestureLockIsOn"];
        }
    }
    else
    {
        sender.on = NO;
    }
}

-(void)showChangeGestureLockCell
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

-(void)hideChangeGestureLockCell
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (IBAction)numberSwitchDidClick:(UISwitch *)sender {
    if((self.gestureSwitch.on == NO) && (self.fingerprintSwitch.on == NO))
    {
        if(sender.on == YES)
        {
            //[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"numberLockIsOn"];
        }
        else
        {
            //[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"nuumberLockIsOn"];
        }
    }
    else
    {
        sender.on = NO;
    }
}

- (IBAction)fingerprintSwitchDidClick:(UISwitch *)sender {
    if((self.gestureSwitch.on == NO) && (self.numberSwitch.on == NO))
    {
        if(sender.on == YES)
        {
            //[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"fingerprintLockIsOn"];
        }
        else
        {
            //[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"fingerprintLockIsOn"];
        }
    }
    else
    {
        sender.on = NO;
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
        }
        return cell;
    } else {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

#pragma mark - TableView Delegate

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
//}

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
    if (indexPath.section == 0 && indexPath.row == 1)
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
    
    if (indexPath.section == 0 && indexPath.row == 1)
    {
        [CLLockVC showModifyLockVCInVC:self successBlock:^(CLLockVC *lockVC, NSString *pwd) {
            [lockVC dismiss:.5f];
        }];
    }
}
@end
