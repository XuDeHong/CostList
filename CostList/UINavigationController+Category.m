//
//  UINavigationController+Category.m
//  CostList
//
//  Created by 许德鸿 on 16/9/4.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "UINavigationController+Category.h"

@implementation UINavigationController (Category)

//重写系统内部的方法，类别的优先级比较高，系统自带的方法则会忽略
- (UIViewController *)childViewControllerForStatusBarStyle
{
    return  self.visibleViewController;     //调用显示的视图控制器的preferredStatusBarStyle方法
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
    return self.visibleViewController;      //调用显示的视图控制器的prefersStatusBarHidden方法
}

@end
