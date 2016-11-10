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

@interface AppDelegate ()

@property (strong,nonatomic) CLLocationManager *locationManager;   //位置管理器
@property (strong,nonatomic) DataModelHandler *dataModelHandler;    //数据处理器

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self initApp]; //初始化应用
    
    return YES;
}

-(void)initApp
{
    //创建数据处理器
    self.dataModelHandler = [[DataModelHandler alloc] init];
    //获取TabBarController
    MyTabBarController *tabBarController = (MyTabBarController *)self.window.rootViewController;
    tabBarController.dataModelHandler = self.dataModelHandler;  //传递指针
    
    //请求用户获取位置的权限
    self.locationManager = [[CLLocationManager alloc] init];
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    //设置3D Touch
    UIApplicationShortcutIcon *icon = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeAdd];
    UIApplicationShortcutItem *addItem = [[UIApplicationShortcutItem alloc] initWithType:@"com.XuDeHong.CostList.Add" localizedTitle:NSLocalizedString(@"添加账目", @"添加账目") localizedSubtitle:nil icon:icon userInfo:nil];
    [UIApplication sharedApplication].shortcutItems = @[addItem];
}

-(void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
    MyTabBarController *tabbarController = (MyTabBarController *)self.window.rootViewController;
    if([shortcutItem.type isEqualToString:@"com.XuDeHong.CostList.Add"])    //快速进入添加账目界面
    {
        [tabbarController showAddOrEditItemControllerWithDataModel:nil];
    }
    
    if(completionHandler)
    {
        completionHandler(YES);
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    BOOL gestureLockIsOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"gestureLockIsOn"];
    BOOL numberLockIsOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"numberLockIsOn"];
    BOOL fingerprintLockIsOn = [[NSUserDefaults standardUserDefaults
                                 ] boolForKey:@"fingerprintLockIsOn"];
    if(gestureLockIsOn)
    {
        [CLLockVC showVerifyLockVCInVC:self.window.rootViewController forgetPwdBlock:^{
            //忘记密码
        } successBlock:^(CLLockVC *lockVC, NSString *pwd) {
            [lockVC dismiss:0.5f];
        }];
    }
    else if(numberLockIsOn)
    {
        
    }
    else if(fingerprintLockIsOn)
    {
        
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
