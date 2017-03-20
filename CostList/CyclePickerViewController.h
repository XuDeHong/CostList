//
//  CyclePickerViewController.h
//  CostList
//
//  Created by 许德鸿 on 2017/3/19.
//  Copyright © 2017年 XuDeHong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CyclePickerViewController;

//定义协议和方法
@protocol CyclePickerViewControllerDelegate <NSObject>

-(void)cyclePickerViewController:(CyclePickerViewController *)controller didChooseCycle:(NSString *)cycle;

@end

@interface CyclePickerViewController : UIViewController

@property (nonatomic,weak) id <CyclePickerViewControllerDelegate> delegate;//指向代理
@property (nonatomic,copy) NSString *currentCycle;
@property (nonatomic,strong) UIView *background;    //半透明黑色背景

@end
