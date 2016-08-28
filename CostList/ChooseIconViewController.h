//
//  ChooseIconViewController.h
//  CostList
//
//  Created by 许德鸿 on 16/8/17.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChooseIconViewController;

//定义协议和方法
@protocol ChooseIconViewControllerDelegate <NSObject>

-(void)chooseIconViewController:(ChooseIconViewController *)controller didChooseIcon:(NSString *)iconName andDisplayName:(NSAttributedString *)displayName;

@end

@interface ChooseIconViewController : UIViewController

@property (nonatomic,weak) id <ChooseIconViewControllerDelegate> delegate;  //指向代理

@end
