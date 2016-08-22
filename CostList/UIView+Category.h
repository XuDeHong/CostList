//
//  UIView+Category.h
//  CostList
//
//  Created by 许德鸿 on 16/8/8.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Category)

@property (nonatomic, assign)CGFloat centerX;   //中心横坐标
@property (nonatomic, assign)CGFloat centerY;   //中心纵坐标
@property (nonatomic, assign)CGFloat height;    //高度
@property (nonatomic, assign)CGFloat width;     //宽度
@property (nonatomic, assign)CGFloat x;         //原点（视图左上角）横坐标
@property (nonatomic, assign)CGFloat y;         //原点（视图左上角）纵坐标
@property (nonatomic, assign)CGSize size;       //视图大小

@end
