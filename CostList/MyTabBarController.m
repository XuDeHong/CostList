//
//  MyTabBarController.m
//  CostList
//
//  Created by 许德鸿 on 16/8/8.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "MyTabBarController.h"
#import "MyTabBar.h"
#import "AddItemViewController.h"
#import "UIViewController+Category.h"
#import "MyNavigationController.h"
#import "ListTableViewController.h"
#import "ChartTableViewController.h"

@interface MyTabBarController () <MyTabBarDelegate,AddItemViewControllerDelegate> //实现自定义TabBar协议

@property (nonatomic,strong) ListTableViewController *listController;
@property (nonatomic,strong) ChartTableViewController *chartController;

@end

@implementation MyTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //设置TabBar上第一个Item（明细）选中时的图片
    UIImage *listActive = [UIImage imageNamed:@"ListIcon - Active(blue)"];
    UITabBarItem *listItem = self.tabBar.items[0];
    //始终按照原图片渲染
    listItem.selectedImage = [listActive imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    
    //设置TabBar上第二个Item（报表）选中时的图片
    UIImage *chartActive = [UIImage imageNamed:@"ChartIcon - Active(blue)"];
    UITabBarItem *chartItem = self.tabBar.items[1];
    //始终按照原图片渲染
    chartItem.selectedImage = [chartActive imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    //创建自定义TabBar
    MyTabBar *myTabBar = [[MyTabBar alloc] init];
    myTabBar.myTabBarDelegate = self;
    
    //利用KVC替换默认的TabBar
    [self setValue:myTabBar forKey:@"tabBar"];
    
    self.listController = self.viewControllers[0];  //获取明细页面控制器
    
    self.listController.managedObjectContext = self.managedObjectContext;   //传递指针
    
    self.chartController = self.viewControllers[1]; //获取报表页面控制器
    
    self.chartController.managedObjectContext = self.managedObjectContext;  //传递指针
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    //设置TabBar的tintColor
    self.tabBar.tintColor = GLOBAL_TINT_COLOR;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showSlideMenuController
{
    //显示侧栏
    [self.itrAirSideMenu presentLeftMenuViewController];
}

-(void)showAddOrEditItemControllerWithDataModel:(CostItem *)costItem;
{
    //创建添加记录页面视图控制器，从AddItemViewController StoryBoard中的单独控制器创建
    MyNavigationController *addItemNavigationController = (MyNavigationController *)[AddItemViewController instanceFromStoryboardV2];
    CGSize backgroundSize = CGSizeMake(addItemNavigationController.navigationBar.width, addItemNavigationController.navigationBar.height + STATUS_BAR_HEIGHT);
    UIImage *background = [UIImage imageWithColor:GLOBAL_TINT_COLOR andSize:backgroundSize];
    //设置导航栏背景图片
    [addItemNavigationController.navigationBar setBackgroundImage:background forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
    //设置导航栏不透明
    [addItemNavigationController.navigationBar setTranslucent:NO];
    //设置导航栏按钮字体颜色
    addItemNavigationController.navigationBar.tintColor = [UIColor whiteColor];
    //设置导航栏标题字体颜色
    [addItemNavigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    //设置代理
    AddItemViewController *controller = (AddItemViewController *)addItemNavigationController.topViewController;
    controller.delegate = self;
    controller.managedObjectContext = self.managedObjectContext;    //传递指针
    if(costItem != nil) controller.itemToEdit = costItem;   //如果是点击账目进入编辑，则传递数据模型
    //显示控制器
    [self presentViewController:addItemNavigationController animated:YES completion:nil];
}

-(MyNavigationController *)getAddItemViewControllerToPreViewForDataModel:(CostItem *)costItem
{
    //创建添加记录页面视图控制器，从AddItemViewController StoryBoard中的单独控制器创建
    MyNavigationController *addItemNavigationController = (MyNavigationController *)[AddItemViewController instanceFromStoryboardV2];
    CGSize backgroundSize = CGSizeMake(addItemNavigationController.navigationBar.width, addItemNavigationController.navigationBar.height + STATUS_BAR_HEIGHT);
    UIImage *background = [UIImage imageWithColor:GLOBAL_TINT_COLOR andSize:backgroundSize];
    //设置导航栏背景图片
    [addItemNavigationController.navigationBar setBackgroundImage:background forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
    //设置导航栏不透明
    [addItemNavigationController.navigationBar setTranslucent:NO];
    //设置导航栏按钮字体颜色
    addItemNavigationController.navigationBar.tintColor = [UIColor whiteColor];
    //设置导航栏标题字体颜色
    [addItemNavigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    AddItemViewController *controller = (AddItemViewController *)addItemNavigationController.topViewController;
    if(costItem != nil) controller.itemToEdit = costItem;   //传递数据模型

    return addItemNavigationController;
}

-(void)didClickDeleteBtnInPreviewWithIndexPath:(NSIndexPath *)indexPath
{
    [self.listController confirmDeleteDataAtIndexPath:indexPath];   //peek预览时点击删除按钮
}

#pragma mark - MyTabBar Delegate
-(void)addButtonClick:(MyTabBar *)tabBar
{
    [self showAddOrEditItemControllerWithDataModel:nil];
}

#pragma mark - AddItemViewController Delegate
-(void)addItemViewControllerDidSaveData:(AddItemViewController *)controller
{
    if(self.selectedIndex == 1) //如果当前处于图表界面，则转换到明细界面
    {
        self.selectedIndex = 0;
    }
}

@end
