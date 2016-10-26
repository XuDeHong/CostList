//
//  ListTableViewController.h
//  CostList
//
//  Created by 许德鸿 on 16/8/8.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListTableViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *monthPickerButton;  //月份选择器按钮

@property (strong,nonatomic) DataModelHandler *dataModelHandler;    //数据处理器

-(void)confirmDeleteDataAtIndexPath:(NSIndexPath *)indexPath;

@end
