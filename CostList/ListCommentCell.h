//
//  ListCommentCell.h
//  CostList
//
//  Created by 许德鸿 on 16/9/10.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListCommentCell : UITableViewCell

@property (nonatomic,strong)IBOutlet UILabel *number;   //支出金额
@property (nonatomic,strong)IBOutlet UILabel *title;    //标题
@property (nonatomic,strong)IBOutlet UILabel *comment;  //备注
@property (nonatomic,strong)IBOutlet UIImageView *imageIndicate; //图片标识

@end
