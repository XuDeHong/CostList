//
//  YearPickerViewController.h
//  CostList
//
//  Created by 许德鸿 on 16/8/12.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YearPickerViewController;

//定义协议和方法
@protocol YearPickerViewControllerDelegate <NSObject>

-(void)yearPickerViewController:(YearPickerViewController *)controller chooseYear:(NSString *)year;

@end

@interface YearPickerViewController : UIViewController

@property (nonatomic,weak) id <YearPickerViewControllerDelegate> delegate;//指向代理
@property (nonatomic,strong) NSString *currentYear;

//显示YearPickerViewController
-(void)presentInParentViewController:(UIViewController *)parentViewController;

@end
