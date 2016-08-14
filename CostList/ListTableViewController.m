//
//  ListTableViewController.m
//  CostList
//
//  Created by 许德鸿 on 16/8/8.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "ListTableViewController.h"
#import "MonthPickerViewController.h"
#import "UIView+Category.h"

static NSString *MonthPickerViewControllerNibName = @"MonthPickerViewController";
static NSString *ListCellIdentifier = @"ListCell";

@interface ListTableViewController () <MonthPickerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *upBackgroundView;  //指向界面上部的视图，用于设置背景色
@property (weak,nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong,nonatomic) MonthPickerViewController *monthPickerViewController;
@property (weak, nonatomic) IBOutlet UIButton *monthPickerButton;
@end

@implementation ListTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self customizeAppearence]; //设置UI元素
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy年"];
    NSString *year = [formatter stringFromDate:[NSDate date]];
    [formatter setDateFormat:@"MM月"];
    NSString *month = [formatter stringFromDate:[NSDate date]];
    NSLog(@"%@%@",year,month);
    
    //初始化月份选择按钮标题为当前年月
    [self.monthPickerButton setTitle:[NSString stringWithFormat:@"%@%@",year,month] forState:UIControlStateNormal];
}


-(void)customizeAppearence
{
    //设置TabBar的tintColor
    self.tabBarController.tabBar.tintColor = GLOBALTINTCOLOR;
    
    //设置界面上部的View的背景色
    self.upBackgroundView.backgroundColor = GLOBALTINTCOLOR;
    
    //设置NavigationBar完全透明，通过UIBarMetricsCompact设置横屏可见，竖屏不可见来间接达到效果，而该应用APP只能竖屏
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavigationBarBackground"] forBarMetrics:UIBarMetricsCompact];
    
    //设置NavigationBarItem的颜色
    self.navigationBar.tintColor = [UIColor whiteColor];
    
    //去除NavigationBar下部的横线
    if ([self.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
    {
        NSArray *list=self.navigationBar.subviews;
        for (id obj in list)
        {
            if ([obj isKindOfClass:[UIImageView class]])
            {
                UIImageView *imageView=(UIImageView *)obj;
                NSArray *list2=imageView.subviews;
                for (id obj2 in list2)
                {
                    if ([obj2 isKindOfClass:[UIImageView class]])
                    {
                        UIImageView *imageView2=(UIImageView *)obj2;
                        imageView2.hidden=YES;
                    }
                }
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)monthPickerButtonDidClick:(id)sender {
    self.monthPickerViewController = [[MonthPickerViewController alloc] initWithNibName:@"MonthPickerViewController" bundle:nil];
    self.monthPickerViewController.delegate = self;
    //显示月份选择器，将MonthPickerViewController嵌入到MyTabBarController
    [self.monthPickerViewController presentInParentViewController:self.parentViewController];
}

#pragma mark - MonthPickerViewControllerDelegate

-(void)chooseMonthAndYear:(NSString *)yearAndMonth
{
    NSLog(@"Choose a month! %@",yearAndMonth);
    [self.monthPickerButton setTitle:[NSString stringWithFormat:@"%@",yearAndMonth] forState:UIControlStateNormal];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/


@end
