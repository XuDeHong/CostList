//
//  MonthValueFormatter.m
//  CostList
//
//  Created by 许德鸿 on 2016/10/11.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "MonthValueFormatter.h"


@implementation MonthValueFormatter

- (NSString *)stringForValue:(double)value axis:(ChartAxisBase *)axis
{
    return [NSString stringWithFormat:@"%.0f月",value];  //返回折线图横坐标格式化字符串
}

@end
