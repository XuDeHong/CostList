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
        self.alertID = [aDecoder decodeObjectForKey:@"alertID"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.alertTitle forKey:@"alertTitle"];
    [aCoder encodeObject:self.alertTime forKey:@"alertTime"];
    [aCoder encodeObject:self.alertCycle forKey:@"alertCycle"];
    [aCoder encodeObject:self.alertID forKey:@"alertID"];
}

+(NSString *)nextNotificationID
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger notificationId = [defaults integerForKey:@"NotificationID"];
    [defaults setInteger:notificationId+1 forKey:@"NotificationID"];
    [defaults synchronize];
    return [NSString stringWithFormat: @"%ld",notificationId];
}

@end
