//
//  SlideMenuViewController.h
//  CostList
//
//  Created by 许德鸿 on 16/8/31.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ITRAirSideMenu.h"

@interface SlideMenuViewController : UITableViewController

@property (weak,nonatomic) ITRAirSideMenu *itrAirSideMenu;  //指向侧栏

@end
