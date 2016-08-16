//
//  UIImage+Category.m
//  CostList
//
//  Created by 许德鸿 on 16/8/16.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "UIImage+Category.h"

@implementation UIImage (Category)

+(UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;
{
        //描述一个矩形
        CGRect rect = CGRectMake(0.0f, 0.0f,size.width,size.height);
        //开启图形上下文
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
        //获得图形上下文
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        //使用color演示填充上下文
        CGContextSetFillColorWithColor(ctx, [color CGColor]);
        //渲染上下文
        CGContextFillRect(ctx, rect);
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        //关闭图形上下文
        UIGraphicsEndImageContext();
        return image;
}

@end
