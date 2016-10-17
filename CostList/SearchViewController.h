//
//  SearchViewController.h
//  CostList
//
//  Created by 许德鸿 on 2016/10/16.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UIViewController

@property (assign, nonatomic, getter=isLeftMenuVisible) BOOL isVisible;
@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;

@end
