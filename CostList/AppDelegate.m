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


@interface AppDelegate ()

@property (strong,nonatomic) CLLocationManager * locationManager;   //位置管理器
@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic,strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //获取TabBarController
    MyTabBarController *tabBarController = (MyTabBarController *)self.window.rootViewController;
    
    tabBarController.managedObjectContext = self.managedObjectContext;  //传递指针
    
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

#pragma mark - Core Data
-(NSManagedObjectModel *)managedObjectModel
{
    if(_managedObjectModel == nil)
    {
        NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"DataModel" ofType:@"momd"];
        NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return _managedObjectModel;
}

-(NSString *)documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths lastObject];
    NSLog(@"%@",documentsDirectory);
    return documentsDirectory;
}

-(NSString *)dataStorePath
{
    return [[self documentsDirectory] stringByAppendingPathComponent:@"DataStore.sqlite"];
}

-(NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if(_persistentStoreCoordinator == nil)
    {
        NSURL *storeURL = [NSURL fileURLWithPath:[self dataStorePath]];
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        NSError *error;
        if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
        {
            NSLog(@"Error adding persistent store %@,%@",error,[error userInfo]);
            abort();
        }
    }
    return _persistentStoreCoordinator;
    
}

-(NSManagedObjectContext *)managedObjectContext
{
    if(_managedObjectContext == nil)
    {
        NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
        if(coordinator != nil)
        {
            _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        }
    }
    return _managedObjectContext;
}


@end
