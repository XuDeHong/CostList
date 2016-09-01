//
//  SlideMenuViewController.m
//  CostList
//
//  Created by 许德鸿 on 16/8/31.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "SlideMenuViewController.h"
#import "ViewDeck/ViewDeck.h"

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
    
    //设置HeaderView
    self.headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 240)];
    self.headerView.contentMode = UIViewContentModeScaleAspectFill;
    self.headerView.image = [UIImage imageWithColor:self.tableView.backgroundColor andSize:self.headerView.frame.size];
    self.headerView.clipsToBounds = YES;
    self.tableView.tableHeaderView = self.headerView;
    
    self.tableView.separatorStyle = NO;
    
    [self enableTableViewScroll];
}

-(void)dealloc
{
    self.viewDeckController.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //侧栏打开时，状态栏为黑色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //侧栏关闭时，状态栏为白色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

-(void)enableTableViewScroll
{
    //检测TableView内容是否超过屏幕，若超过，则可以滚动,否则禁止滚动
    if(self.tableView.contentSize.height > SCREENHEIGHT || self.tableView.contentSize.height == SCREENHEIGHT)
    {
        self.tableView.scrollEnabled = YES;
    }
    else
    {
        self.tableView.scrollEnabled = NO;
    }
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
