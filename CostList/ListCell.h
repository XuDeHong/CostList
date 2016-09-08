//
//  ListCell.h
//  CostList
//
//  Created by 许德鸿 on 16/9/8.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListCell : UITableViewCell

@property (nonatomic,strong)IBOutlet UIImageView *icon; //图标
@property (nonatomic,strong)IBOutlet UILabel *title;    //标题
@property (nonatomic,strong)IBOutlet UILabel *number;   //支出金额

@end
