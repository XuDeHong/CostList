//
//  UIViewController+Category.h
//  CostList
//
//  Created by 许德鸿 on 16/8/19.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Category)

+(nullable instancetype)instanceFromStoryboardV2;   //快速从多个StoryBoard中取出指定identifier的视图控制器

@end
