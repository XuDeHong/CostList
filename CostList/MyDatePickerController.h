//
//  MyDatePickerController.h
//  CostList
//
//  Created by 许德鸿 on 16/8/21.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import <UIKit/UIKit.h>

//定义协议和方法
@protocol MyDatePickerControllerDelegate <NSObject>

-(void)didChooseDate:(NSString *)date;

@end

@interface MyDatePickerController : UIViewController


@property (nonatomic,weak) id <MyDatePickerControllerDelegate> delegate;//指向代理
@property (nonatomic,strong) NSString *currentDate;
@property (nonatomic,strong) UIView *background;    //半透明黑色背景

@end
