//
//  MyTabBarController.m
//  CostList
//
//  Created by 许德鸿 on 16/8/8.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "MyTabBarController.h"
#import "MyTabBar.h"


@interface MyTabBarController () <MyTabBarDelegate> //实现自定义TabBar协议

@end

@implementation MyTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //创建自定义TabBar
    MyTabBar *myTabBar = [[MyTabBar alloc] init];
    myTabBar.myTabBarDelegate = self;
    
    //利用KVC替换默认的TabBar
    [self setValue:myTabBar forKey:@"tabBar"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showSlideMenuController
{
}

#pragma mark - MyTabBarDelegate
-(void)addButtonClick:(MyTabBar *)tabBar
{
    //测试中间“+”按钮是否可以点击并处理事件
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"test" message:@"Test" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"test" style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:action];
    [self presentViewController:controller animated:YES completion:nil];
}

@end
