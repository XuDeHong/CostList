//
//  DataModelHandler.h
//  CostList
//
//  Created by 许德鸿 on 2016/10/21.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataModelHandler : NSObject

-(CostItem *)createNewDataModel;    //创建一个新的数据实体
-(BOOL)saveData;    //保存数据
-(BOOL)deleteData:(CostItem *)data; //删除数据
-(NSArray *)searchDataByText:(NSString *)text;  //根据备注查找数据

@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;

@end
