//
//  NotificationModel.m
//  CostList
//
//  Created by 许德鸿 on 2017/3/19.
//  Copyright © 2017年 XuDeHong. All rights reserved.
//

#import "NotificationModel.h"

@implementation NotificationModel

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if([super init])
    {
        self.alertTitle = [aDecoder decodeObjectForKey:@"alertTitle"];
        self.alertTime = [aDecoder decodeObjectForKey:@"alertTime"];
        self.alertCycle = [aDecoder decodeObjectForKey:@"alertCycle"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.alertTitle forKey:@"alertTitle"];
    [aCoder encodeObject:self.alertTime forKey:@"alertTime"];
    [aCoder encodeObject:self.alertCycle forKey:@"alertCycle"];
}

@end
