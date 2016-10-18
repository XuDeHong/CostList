//
//  MyTabBarController.h
//  CostList
//
//  Created by 许德鸿 on 16/8/8.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddItemViewController.h"

@class MyNavigationController;

@interface MyTabBarController : UITabBarController <AddItemViewControllerDelegate>

@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;

-(void)showSlideMenuController;

-(void)showAddOrEditItemControllerWithDataModel:(CostItem *)costItem;

-(MyNavigationController *)getAddItemViewControllerToPreViewForDataModel:(CostItem *)costItem;

-(void)didClickDeleteBtnInPreviewWithIndexPath:(NSIndexPath *)indexPath;

@end
