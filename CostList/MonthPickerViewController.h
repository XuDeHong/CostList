//
//  MonthPickerViewController.h
//  CostList
//
//  Created by 许德鸿 on 16/8/12.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MonthPickerViewController;

//定义协议和方法
@protocol MonthPickerViewControllerDelegate <NSObject>

-(void)monthPickerViewController:(MonthPickerViewController *)controller chooseMonthAndYear:(NSString *)yearAndMonth;

@end

@interface MonthPickerViewController : UIViewController

@property (nonatomic,weak) id <MonthPickerViewControllerDelegate> delegate;//指向代理
@property (nonatomic,strong) NSString *currentYearAndMonth;

//显示MonthPickerViewController
-(void)presentInParentViewController:(UIViewController *)parentViewController;

@end
