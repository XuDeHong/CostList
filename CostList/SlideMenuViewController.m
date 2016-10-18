//
//  SlideMenuViewController.m
//  CostList
//
//  Created by 许德鸿 on 16/8/31.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "SlideMenuViewController.h"
#import "ViewDeck/ViewDeck.h"

#define HeaderViewHeightIn4S 65.0f         //4s的headerview高度
#define HeaderViewHeightIn5S 100.0f         //5s的headerview高度
#define HeaderViewHeightIn6S 120.0f         //6s的headerview高度
#define HeaderViewHeightIn6SPLUS 150.0f     //6splus的headerview高度

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
    
    //根据屏幕高度计算headerView高度
    CGFloat headerViewHeight = 0;
    if(DEVICE_IS_IPHONE6SPLUS)
        headerViewHeight = HeaderViewHeightIn6SPLUS;
    else if(DEVICE_IS_IPHONE6S)
        headerViewHeight = HeaderViewHeightIn6S;
    else if(DEVICE_IS_IPHONE5S)
        headerViewHeight = HeaderViewHeightIn5S;
    else
        headerViewHeight = HeaderViewHeightIn4S;
    
    //设置HeaderView
    self.headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width,headerViewHeight)];
    self.headerView.contentMode = UIViewContentModeScaleAspectFill;
    self.headerView.image = [UIImage imageWithColor:[UIColor clearColor] andSize:self.headerView.frame.size];
    self.headerView.clipsToBounds = YES;
    self.tableView.tableHeaderView = self.headerView;
    
    self.tableView.separatorStyle = NO; //去掉分割线
    //设置代理
    self.viewDeckController.delegate = self;
    
    self.tableView.backgroundView = [self getSlideMenuBG];  //设置TableView背景图片
}

-(UIImageView *)getSlideMenuBG
{
    UIImageView *imageview = [[UIImageView alloc] init];
    imageview.frame = CGRectMake(0,0,self.view.width,self.view.height);
    imageview.image = [UIImage imageNamed:@"SlideMenuBG"];
    imageview.contentMode = UIViewContentModeScaleToFill;
    imageview.userInteractionEnabled = NO;
    
    //增加模糊效果
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
    effectview.frame = CGRectMake(0, 0,self.view.width,self.view.height);
    
    [imageview addSubview:effectview];
    
    return imageview;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    self.viewDeckController.delegate = nil;
}

#pragma mark Table View Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

- (void)viewDeckController:(IIViewDeckController*)viewDeckController didCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated
{
    [viewDeckController setNeedsStatusBarAppearanceUpdate];   //更新状态栏的颜色
}

- (void)viewDeckController:(IIViewDeckController*)viewDeckController didOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated
{
    [viewDeckController setNeedsStatusBarAppearanceUpdate];   //更新状态栏的颜色
}

@end
