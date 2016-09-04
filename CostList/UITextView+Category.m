//
//  UITextView+Category.m
//  CostList
//
//  Created by 许德鸿 on 16/8/21.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "UITextView+Category.h"

@implementation UITextView (Category)

//TextView要想在视图调试中显示，需要重写以下两个方法，这会覆盖系统内部原有的方法，因为类别的优先级比较高
- (void)_firstBaselineOffsetFromTop {}
- (void)_baselineOffsetFromBottom {}

@end
