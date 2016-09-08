//
//  MyPhoto.h
//  CostList
//
//  Created by 许德鸿 on 16/9/8.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NYTPhotoViewer/NYTPhoto.h"

@interface MyPhoto : NSObject <NYTPhoto>    //实现查看大图的图片数据模型

@property (nonatomic) UIImage *image;
@property (nonatomic) NSData *imageData;
@property (nonatomic) UIImage *placeholderImage;
@property (nonatomic) NSAttributedString *attributedCaptionTitle;
@property (nonatomic) NSAttributedString *attributedCaptionSummary;
@property (nonatomic) NSAttributedString *attributedCaptionCredit;

@end
