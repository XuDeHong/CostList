//
//  NotificationModel.h
//  CostList
//
//  Created by 许德鸿 on 2017/3/19.
//  Copyright © 2017年 XuDeHong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationModel : NSObject <NSCoding>

//提醒内容
@property (nonatomic,copy) NSString *alertTitle;
//提醒时间
@property (nonatomic,copy) NSString *alertTime;
//提醒周期
@property (nonatomic,copy) NSString *alertCycle;

@end
