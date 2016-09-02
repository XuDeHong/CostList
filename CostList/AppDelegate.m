//
//  AppDelegate.m
//  CostList
//
//  Created by 许德鸿 on 16/8/8.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "AppDelegate.h"
#import "ListTableViewController.h"
#import "ChartTableViewController.h"
#import "SlideMenuViewController.h"
#import "MyTabBarController.h"
#import <CoreLocation/CoreLocation.h>
#import "UIViewController+Category.h"
#import "ViewDeck/ViewDeck.h"

#define SlideMenuWidth 220.0f

@interface AppDelegate ()

@property (strong,nonatomic) CLLocationManager * locationManager;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //设置Status Bar颜色为白色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    //获取TabBarController和TabBar
    MyTabBarController *tabBarController = (MyTabBarController *)self.window.rootViewController;
    
    //创建侧栏菜单视图控制器，从Main.StoryBoard中的单独控制器创建
    SlideMenuViewController *mySlideMenuViewController = [SlideMenuViewController instanceFromStoryboardV2];
    
    //创建侧栏效果控制器
    IIViewDeckController* deckController =  [[IIViewDeckController alloc] initWithCenterViewController:tabBarController leftViewController:[IISideController autoConstrainedSideControllerWithViewController:mySlideMenuViewController] rightViewController:nil];
    //设置侧栏打开时中间主视图的宽度
    deckController.leftSize = SCREENWIDTH - SlideMenuWidth;
    deckController.maxSize = SCREENWIDTH - SlideMenuWidth;
    //设置侧栏打开时中间主视图不可交互
    deckController.centerhiddenInteractivity = IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose;
    //设置为根控制器
    self.window.rootViewController = deckController;
    //请求用户获取位置的权限
    self.locationManager = [[CLLocationManager alloc] init];
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    return YES;
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
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
