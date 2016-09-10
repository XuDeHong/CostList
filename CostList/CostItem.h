//
//  CostItem.h
//  CostList
//
//  Created by 许德鸿 on 16/9/10.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface CostItem : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
+(NSInteger)nextPhotoId;

-(BOOL)hasPhoto;
-(NSString *)photoPath;
-(UIImage *)photoImage;
-(void)removePhotoFile;

@end

NS_ASSUME_NONNULL_END

#import "CostItem+CoreDataProperties.h"
