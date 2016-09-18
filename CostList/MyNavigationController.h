//
//  MyNavigationController.h
//  CostList
//
//  Created by 许德鸿 on 16/9/4.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyNavigationController : UINavigationController

@property (nonatomic,strong) NSIndexPath *indexPathForData; //记录数据模型在TableView的位置

@end
