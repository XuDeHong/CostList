//
//  ListCell.m
//  CostList
//
//  Created by 许德鸿 on 16/9/8.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "ListCell.h"

#define TableRowSeparatorColor [UIColor colorWithRed:216/255.0f green:216/255.0f blue:216/255.0f alpha:0.7]
#define TableViewRowHeight 65

@implementation ListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)drawRect:(CGRect)rect
{
    //添加分割线
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(15,TableViewRowHeight - 1,SCREEN_WIDTH - 15, 1)];
    separator.backgroundColor = TableRowSeparatorColor;
    separator.tag = 500;    //做一个标记，方便获取
    [self.contentView addSubview:separator];
}

@end
