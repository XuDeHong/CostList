//
//  NSNumber+Category.m
//  CostList
//
//  Created by 许德鸿 on 2016/9/25.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "NSNumber+Category.h"

@implementation NSNumber (Category)

-(NSComparisonResult)doubleCompare:(NSNumber *)other
{
    double myValue = [self doubleValue];
    double otherValue= [other doubleValue];
    if(myValue == otherValue) return NSOrderedSame;
    return (myValue < otherValue ? NSOrderedDescending : NSOrderedAscending);
}

@end
