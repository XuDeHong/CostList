//
//  MyTabBarController.m
//  CostList
//
//  Created by 许德鸿 on 16/8/8.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "MyTabBarController.h"
#import "MyTabBar.h"
#import "AddItemViewController.h"
#import "UIViewController+Category.h"
#import "RESideMenu.h"


@interface MyTabBarController () <MyTabBarDelegate> //实现自定义TabBar协议

@end

@implementation MyTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //设置TabBar上第一个Item（明细）选中时的图片
    UIImage *listActive = [UIImage imageNamed:@"ListIcon - Active(blue)"];
    UITabBarItem *listItem = self.tabBar.items[0];
    //始终按照原图片渲染
    listItem.selectedImage = [listActive imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    
    //设置TabBar上第二个Item（报表）选中时的图片
    UIImage *chartActive = [UIImage imageNamed:@"ChartIcon - Active(blue)"];
    UITabBarItem *chartItem = self.tabBar.items[1];
    //始终按照原图片渲染
    chartItem.selectedImage = [chartActive imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    //创建自定义TabBar
    MyTabBar *myTabBar = [[MyTabBar alloc] init];
    myTabBar.myTabBarDelegate = self;
    
    //利用KVC替换默认的TabBar
    [self setValue:myTabBar forKey:@"tabBar"];
    
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    //设置TabBar的tintColor
    self.tabBar.tintColor = GLOBALTINTCOLOR;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showSlideMenuController
{
    //显示侧栏
    [self.sideMenuViewController presentLeftMenuViewController];
}



#pragma mark - MyTabBar Delegate
-(void)addButtonClick:(MyTabBar *)tabBar
{
//    //测试中间“+”按钮是否可以点击并处理事件
//    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"test" message:@"Test" preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *action = [UIAlertAction actionWithTitle:@"test" style:UIAlertActionStyleDefault handler:nil];
//    [controller addAction:action];
//    [self presentViewController:controller animated:YES completion:nil];
    
    //创建添加记录页面视图控制器，从AddItemViewController StoryBoard中的单独控制器创建
    UINavigationController *addItemViewController = (UINavigationController *)[AddItemViewController instanceFromStoryboardV2];
    CGSize backgroundSize = CGSizeMake(addItemViewController.navigationBar.width, addItemViewController.navigationBar.height + StatusBarHeight);
    UIImage *background = [UIImage imageWithColor:GLOBALTINTCOLOR andSize:backgroundSize];
    //设置导航栏背景图片
    [addItemViewController.navigationBar setBackgroundImage:background forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
    //设置导航栏不透明
    [addItemViewController.navigationBar setTranslucent:NO];
    //设置导航栏按钮字体颜色
    addItemViewController.navigationBar.tintColor = [UIColor whiteColor];
    //设置导航栏标题字体颜色
    [addItemViewController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    //显示控制器
    [self presentViewController:addItemViewController animated:YES completion:nil];
}

@end
