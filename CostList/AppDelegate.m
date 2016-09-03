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
#import "ITRAirSideMenu.h"


#define SlideMenuWidth 220.0f   //侧栏宽度

@interface AppDelegate ()

@property (strong,nonatomic) CLLocationManager * locationManager;   //位置管理器

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //获取TabBarController和TabBar
    MyTabBarController *tabBarController = (MyTabBarController *)self.window.rootViewController;
    
    //创建侧栏菜单视图控制器，从Main.StoryBoard中的单独控制器创建
    SlideMenuViewController *mySlideMenuViewController = [SlideMenuViewController instanceFromStoryboardV2];
    
    //创建侧栏效果控制器
    ITRAirSideMenu *itrAirSideMenu = [[ITRAirSideMenu alloc] initWithContentViewController:tabBarController leftMenuViewController:mySlideMenuViewController];
    //设置侧栏背景
    itrAirSideMenu.backgroundImage = [UIImage imageNamed:@"SlideMenuBG"];
    
    //content view shadow properties
    itrAirSideMenu.contentViewShadowColor = [UIColor blackColor];
    itrAirSideMenu.contentViewShadowOffset = CGSizeMake(0, 0);
    itrAirSideMenu.contentViewShadowOpacity = 0.6;
    itrAirSideMenu.contentViewShadowRadius = 12;
    itrAirSideMenu.contentViewShadowEnabled = YES;
    
    //content view animation properties
    itrAirSideMenu.contentViewScaleValue = 0.7f;
    itrAirSideMenu.contentViewRotatingAngle = 10.0f;
    itrAirSideMenu.contentViewTranslateX = 150.0f;
    
    //menu view properties
    itrAirSideMenu.menuViewRotatingAngle = 30.0f;
    itrAirSideMenu.menuViewTranslateX = 130.0f;
    
    mySlideMenuViewController.itrAirSideMenu = itrAirSideMenu;
    tabBarController.itrAirSideMenu = itrAirSideMenu;
    
    //设置为根控制器
    self.window.rootViewController = itrAirSideMenu;
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
