//
//  ChooseIconViewController.h
//  CostList
//
//  Created by 许德鸿 on 16/8/17.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChooseIconViewController;

@protocol ChooseIconViewControllerDelegate <NSObject>

-(void)chooseIconViewController:(ChooseIconViewController *)controller didChooseIcon:(NSString *)iconName;

@end

@interface ChooseIconViewController : UIViewController

@property (nonatomic,weak) id <ChooseIconViewControllerDelegate> delegate;

@end
