//
//  MyTabBar.h
//  CostList
//
//  Created by 许德鸿 on 16/8/8.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyTabBar;

//MyTabBar的代理必须实现addButtonClick，以响应中间“+”按钮的点击事件
@protocol MyTabBarDelegate <NSObject>

-(void)addButtonClick:(MyTabBar *)tabBar;

@end

@interface MyTabBar : UITabBar

//指向MyTabBar的代理
@property (nonatomic,weak) id<MyTabBarDelegate> myTabBarDelegate;

@end
