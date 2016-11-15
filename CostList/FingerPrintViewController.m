//
//  FingerPrintViewController.m
//  CostList
//
//  Created by 许德鸿 on 2016/11/11.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "FingerPrintViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface FingerPrintViewController ()

@end

@implementation FingerPrintViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self evaluateAuthenticate];
}

- (IBAction)fingerLockBtnDidClick:(UIButton *)sender {
    [self evaluateAuthenticate];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;    //将状态栏设为白色
}

-(BOOL)prefersStatusBarHidden
{
    return NO;  //不隐藏状态栏
}

- (void)evaluateAuthenticate
{
    //创建LAContext
    LAContext* context = [[LAContext alloc] init];
    NSError* error = nil;
    NSString* result = @"请验证已有指纹";
    
    //首先使用canEvaluatePolicy 判断设备支持状态
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        //支持指纹验证
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:result reply:^(BOOL success, NSError *error) {
            if (success) {
                //验证成功，主线程处理UI
                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            }
            else
            {
                NSString *text = nil;
                NSLog(@"%@",error.localizedDescription);
                switch (error.code) {
                    case LAErrorSystemCancel:
                    {
                        //系统取消授权，如其他APP切入
                        break;
                    }
                    case LAErrorUserCancel:
                    {
                        //用户取消验证Touch ID
                        break;
                    }
                    case LAErrorAuthenticationFailed:
                    {
                        //授权失败
                        break;
                    }
                    case LAErrorPasscodeNotSet:
                    {
                        text = @"未设置TouchID信息，请设置后重试";//系统未设置密码
                        break;
                    }
                    case LAErrorTouchIDNotAvailable:
                    {
                        text = @"TouchID不可用，设备不支持或未打开，若设备支持则打开后重试";//设备Touch ID不可用，例如未打开
                        break;
                    }
                    case LAErrorTouchIDNotEnrolled:
                    {
                        text = @"未录入TouchID信息，请录入后重试";//设备Touch ID不可用，用户未录入
                        break;
                    }
                    case LAErrorUserFallback:
                    {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            //用户选择输入密码，切换主线程处理
                            
                        }];
                        break;
                    }
                    default:
                    {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            //其他情况，切换主线程处理
                        }];
                        break;
                    }
                }
                if(text != nil)
                {
                    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"提示" message:text preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
                    [controller addAction:action];
                    [self presentViewController:controller animated:YES completion:nil];
                }
            }
        }];
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

    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
