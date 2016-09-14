//
//  AddItemViewController.h
//  CostList
//
//  Created by 许德鸿 on 16/8/17.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddItemViewController;

@protocol AddItemViewControllerDelegate <NSObject>

-(void)addItemViewControllerDidSaveData:(AddItemViewController *)controller;

@end

@interface AddItemViewController : UITableViewController

@property (nonatomic,weak) id <AddItemViewControllerDelegate> delegate;//指向代理
@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) CostItem *itemToEdit;

@end
