//
//  NSNumber+Category.h
//  CostList
//
//  Created by 许德鸿 on 2016/9/25.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (Category)

-(NSComparisonResult)doubleCompare:(NSNumber *)other;   //以降序排序

@end
