//
//  CostItem+CoreDataProperties.h
//  CostList
//
//  Created by 许德鸿 on 16/9/15.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CostItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface CostItem (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *category;
@property (nullable, nonatomic, retain) NSString *categoryName;
@property (nullable, nonatomic, retain) NSString *comment;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSString *location;
@property (nullable, nonatomic, retain) NSNumber *money;
@property (nullable, nonatomic, retain) NSNumber *photoId;
@property (nullable, nonatomic, retain) NSDate *createTime;

@end

NS_ASSUME_NONNULL_END
