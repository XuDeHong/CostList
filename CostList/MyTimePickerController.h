//
//  MyTimePickerController.h
//  CostList
//
//  Created by 许德鸿 on 2017/3/19.
//  Copyright © 2017年 XuDeHong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyTimePickerController;

//定义协议和方法
@protocol MyTimePickerControllerDelegate <NSObject>

-(void)myTimePickerController:(MyTimePickerController *)controller didChooseTime:(NSString *)time;

@end

@interface MyTimePickerController : UIViewController

@property (nonatomic,weak) id <MyTimePickerControllerDelegate> delegate;//指向代理
@property (nonatomic,copy) NSString *currentTime;
@property (nonatomic,strong) UIView *background;    //半透明黑色背景

@end
