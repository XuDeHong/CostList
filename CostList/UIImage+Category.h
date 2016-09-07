//
//  UIImage+Category.h
//  CostList
//
//  Created by 许德鸿 on 16/8/16.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Category)

+(UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;   //根据颜色和大小生成一张纯色图片

-(UIImage *) imageCompressForSize:(CGSize)size; //给定size，按比例缩放图片

@end
