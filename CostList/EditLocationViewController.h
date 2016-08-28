//
//  EditLocationViewController.h
//  CostList
//
//  Created by 许德鸿 on 16/8/19.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EditLocationViewController;

//定义协议和方法
@protocol EditLocationViewControllerDelegate <NSObject>

-(void)editLocationViewController:(EditLocationViewController *)controller editedLocation:(NSString *)location;

@end

@interface EditLocationViewController : UIViewController

@property (nonatomic,weak) id <EditLocationViewControllerDelegate> delegate;//指向代理
@property (nonatomic,strong) NSString *currentLocation;

@end
