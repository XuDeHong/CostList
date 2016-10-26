//
//  MyNavigationController.m
//  CostList
//
//  Created by 许德鸿 on 16/9/4.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "MyNavigationController.h"
#import "MyTabBarController.h"

@implementation MyNavigationController

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;    //将状态栏设为白色
}

-(BOOL)prefersStatusBarHidden
{
    return NO;  //不隐藏状态栏
}

#pragma mark - 3D Touch

- (NSArray<id<UIPreviewActionItem>> *)previewActionItems {
    // setup a list of preview actions
    //peek预览界面删除按钮的响应
    UIPreviewAction *delete = [UIPreviewAction actionWithTitle:@"删除" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        //获取myTabBarController
        MyTabBarController *tabBarController = (MyTabBarController *)ROOT_VIEW_CONTROLLER;
        //调用方法
        [tabBarController didClickDeleteBtnInPreviewWithIndexPath:self.indexPathForData];
    }];
    
    NSArray *actions = @[delete];
    
    // and return them (return the array of actions instead to see all items ungrouped)
    return actions;
}

@end
