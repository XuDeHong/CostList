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

-(UIImage *) imageCompressForSize:(CGSize)size
{
    
    UIImage *newImage = nil;
    CGSize imageSize = self.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = size.width;
    CGFloat targetHeight = size.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if(CGSizeEqualToSize(imageSize, size) == NO)
    {
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if(widthFactor > heightFactor)
        {
            scaleFactor = widthFactor;
        }
        else
        {
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        if(widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if(widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(size);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [self drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
    {
        NSLog(@"scale image fail");
    }
    
    UIGraphicsEndImageContext();
    return newImage;
}

@end
