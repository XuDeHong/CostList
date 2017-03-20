//
//  EditAlertTitleViewController.h
//  CostList
//
//  Created by 许德鸿 on 2017/3/20.
//  Copyright © 2017年 XuDeHong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EditAlertTitleViewController;

//定义协议和方法
@protocol EditAlertTitleViewControllerDelegate <NSObject>

-(void)editAlertTitleViewController:(EditAlertTitleViewController *)controller editedAlertTitle:(NSString *)alertTitle;

@end


@interface EditAlertTitleViewController : UIViewController

@property (nonatomic,weak) id <EditAlertTitleViewControllerDelegate> delegate;//指向代理
@property (nonatomic,strong) NSString *currentTitle;

@end
