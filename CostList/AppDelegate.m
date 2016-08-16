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


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //获取TabBarController和TabBar
    MyTabBarController *tabBarController = (MyTabBarController *)self.window.rootViewController;
    UITabBar *tabBar = tabBarController.tabBar;
    
    //设置TabBar上第一个Item（明细）选中时的图片
    UIImage *listActive = [UIImage imageNamed:@"ListIcon - Active(blue)"];
    UITabBarItem *listItem = tabBar.items[0];
    //始终按照原图片渲染
    listItem.selectedImage = [listActive imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    
    //设置TabBar上第二个Item（报表）选中时的图片
    UIImage *chartActive = [UIImage imageNamed:@"ChartIcon - Active(blue)"];
    UITabBarItem *chartItem = tabBar.items[1];
    //始终按照原图片渲染
    chartItem.selectedImage = [chartActive imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    //创建侧栏菜单视图控制器，从StoryBoard中的单独控制器创建
//    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    
//    SlideMenuViewController *slideMenuViewController = [storyBoard instantiateViewControllerWithIdentifier:@"SlideMenuViewController"];
    
    
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
