//
//  ITRAirSideMenu+Category.m
//  CostList
//
//  Created by 许德鸿 on 16/9/4.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "ITRAirSideMenu+Category.h"
#import "SearchViewController.h"

@implementation ITRAirSideMenu (Category)

- (UIStatusBarStyle)preferredStatusBarStyle //侧栏效果控制器作为根视图控制器，会自动调用这个方法
{
    if(self.isLeftMenuVisible)
        return UIStatusBarStyleDefault;     //侧栏显示时状态栏为黑色
    else
    {
        SearchViewController *controller = (SearchViewController *)self.presentedViewController;
        if((controller != nil) && (controller.isVisible == YES))
        {
            return UIStatusBarStyleDefault; //如果是搜索控制器，则显示黑色
        }
        return UIStatusBarStyleLightContent;    //侧栏显示时状态栏为白色
    }
}

-(BOOL)prefersStatusBarHidden
{
    return NO;  //不隐藏状态栏
}

@end
