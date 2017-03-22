//
//  AppDelegate.m
//  CostList
//
//  Created by 许德鸿 on 16/8/8.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "AppDelegate.h"
#import "MyTabBarController.h"
#import <CoreLocation/CoreLocation.h>
#import "CLLockVC.h"
#import "FingerPrintViewController.h"
#import "UIViewController+Category.h"
#import <UserNotifications/UserNotifications.h>

#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>

//微信SDK头文件
#import "WXApi.h"

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@property (strong,nonatomic) CLLocationManager *locationManager;   //位置管理器
@property (strong,nonatomic) DataModelHandler *dataModelHandler;    //数据处理器

@end

@implementation AppDelegate
{
    BOOL _isFingerPrintCheck;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self initApp]; //初始化应用
    
    _isFingerPrintCheck = NO;
    
    return YES;
}

-(void)initApp
{
    //创建数据处理器
    self.dataModelHandler = [[DataModelHandler alloc] init];
    //获取TabBarController
    MyTabBarController *tabBarController = (MyTabBarController *)self.window.rootViewController;
    tabBarController.dataModelHandler = self.dataModelHandler;  //传递指针
    
    //请求用户是否可以获取位置
    self.locationManager = [[CLLocationManager alloc] init];
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    //设置3D Touch
    UIApplicationShortcutIcon *icon = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeAdd];
    UIApplicationShortcutItem *addItem = [[UIApplicationShortcutItem alloc] initWithType:@"com.XuDeHong.CostList.Add" localizedTitle:NSLocalizedString(@"添加账目", @"添加账目") localizedSubtitle:nil icon:icon userInfo:nil];
    [UIApplication sharedApplication].shortcutItems = @[addItem];
    
    //初始化ShareSDK分享功能
    [ShareSDK registerApp:@"1ba018c1591b8" activePlatforms:@[@(SSDKPlatformTypeWechat)] onImport:^(SSDKPlatformType platformType){
        switch (platformType) {
            case SSDKPlatformTypeWechat:
                [ShareSDKConnector connectWeChat:[WXApi class]];
                break;
            default:
                break;
        }
    } onConfiguration:^(SSDKPlatformType platformType,NSMutableDictionary *appInfo){
        switch (platformType) {
            case SSDKPlatformTypeWechat:
                [appInfo SSDKSetupWeChatByAppId:@"wx4b7565ee56bb961c" appSecret:@"9379bb40b6f95f04bb26635c8683c795"];
                break;
                
            default:
                break;
        }
    }];
    
    //请求用户是否可以推送本地通知
    //iOS 10 before
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    
    //iOS 10
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"request authorization succeeded!");
        }
    }];
    center.delegate = self; //通知中心的代理为AppDelegate
}

-(void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
    MyTabBarController *tabBarController = (MyTabBarController *)self.window.rootViewController;
    if([shortcutItem.type isEqualToString:@"com.XuDeHong.CostList.Add"])    //快速进入添加账目界面
    {
        [tabBarController showAddOrEditItemControllerWithDataModel:nil];
    }
    
    if(completionHandler)
    {
        completionHandler(YES);
    }
}

#pragma mark - UserNotification Delegate
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{   //当应用处于前台时，不显示badge，只显示alert和sound
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound);
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler
{
    NSString *categoryIdentifier = response.notification.request.content.categoryIdentifier;
    //识别需要被处理的拓展
    if ([categoryIdentifier isEqualToString:@"NotificationCategory"])
    {   //识别用户点击的是哪个 action
        if ([response.actionIdentifier isEqualToString:@"addItemAction"])
        {
            MyTabBarController *tabBarController = (MyTabBarController *)self.window.rootViewController;
            [tabBarController showAddOrEditItemControllerWithDataModel:nil];
            
        }
    }
    completionHandler();
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    _isFingerPrintCheck = NO;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    BOOL gestureLockIsOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"gestureLockIsOn"];
    BOOL fingerprintLockIsOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"fingerprintLockIsOn"];
    if(gestureLockIsOn)
    {
        [CLLockVC showVerifyLockVCInVC:self.window.rootViewController forgetPwdBlock:^{
            //忘记密码处理
        } successBlock:^(CLLockVC *lockVC, NSString *pwd) {
            [lockVC dismiss:0.5f];
        }];
    }
    else if(fingerprintLockIsOn && (!_isFingerPrintCheck))
    {
        _isFingerPrintCheck = YES;
        FingerPrintViewController *fingerLockView = [FingerPrintViewController instanceFromStoryboardV2];
        [self.window.rootViewController presentViewController:fingerLockView animated:YES completion:nil];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
