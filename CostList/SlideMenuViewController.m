//
//  SlideMenuViewController.m
//  CostList
//
//  Created by 许德鸿 on 16/8/31.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "SlideMenuViewController.h"
#import "ViewDeck/ViewDeck.h"

#define HeaderViewAndScreenHeightRatio 240.0/667.0  //当屏幕为6或6s的尺寸（高度667）时，headerView高度为240

@interface SlideMenuViewController () <IIViewDeckControllerDelegate>

@property (nonatomic, strong) UIImageView *headerView;

@end

@implementation SlideMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //设置代理
    self.viewDeckController.delegate = self;
    //根据屏幕高度和比例计算headerView高度
    CGFloat headerViewHeight = HeaderViewAndScreenHeightRatio * SCREENHEIGHT;
    
    //设置HeaderView
    self.headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width,headerViewHeight)];
    self.headerView.contentMode = UIViewContentModeScaleAspectFill;
    self.headerView.image = [UIImage imageWithColor:[UIColor clearColor] andSize:self.headerView.frame.size];
    self.headerView.clipsToBounds = YES;
    self.tableView.tableHeaderView = self.headerView;
    
    self.tableView.separatorStyle = NO; //去掉分割线
    
}

-(void)dealloc
{
    self.viewDeckController.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IIViewDeckControllerDelegate
- (void)viewDeckController:(IIViewDeckController*)viewDeckController applyShadow:(CALayer*)shadowLayer withBounds:(CGRect)rect
{
    //默认的阴影效果，不过取消了阴影的动画
    shadowLayer.masksToBounds = NO;
    shadowLayer.shadowRadius = 10;
    shadowLayer.shadowOpacity = 0.5;
    shadowLayer.shadowColor = [[UIColor blackColor] CGColor];
    shadowLayer.shadowOffset = CGSizeZero;
    shadowLayer.shadowPath = [[UIBezierPath bezierPathWithRect:shadowLayer.bounds] CGPath];
}

@end
