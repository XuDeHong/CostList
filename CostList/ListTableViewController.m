//
//  ListTableViewController.m
//  CostList
//
//  Created by 许德鸿 on 16/8/8.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "ListTableViewController.h"
#import "MonthPickerViewController.h"
#import "MyTabBarController.h"
#import "ListCell.h"
#import "ListCommentCell.h"


static NSString *ListCellIdentifier = @"ListCell";
static NSString *ListCommentCellIdentifier = @"ListCommentCell";

@interface ListTableViewController () <MonthPickerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *upBackgroundView;  //指向界面上部的视图，用于设置背景色
@property (weak,nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong,nonatomic) MonthPickerViewController *monthPickerViewController;
@property (weak,nonatomic) MyTabBarController *myTabBarController;
@property (weak, nonatomic) IBOutlet UITableView *listTableView;

@end

@implementation ListTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self customizeAppearence]; //设置UI元素
    
    //去除多余的空行和分割线
    self.listTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self initMonthPickerButton]; //初始化月份选择器按钮
}


-(void)customizeAppearence
{
    //设置界面上部的View的背景色
    self.upBackgroundView.backgroundColor = GLOBAL_TINT_COLOR;
    
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIImageView *noDataPlaceholder = [[UIImageView alloc] initWithFrame:CGRectMake(self.listTableView.x, self.listTableView.y, self.listTableView.width, self.listTableView.height)];
    UIImage *noDataImage = [UIImage imageNamed:@"NoDataImage"];
    noDataPlaceholder.image = noDataImage;
    
    if([self.dataModelArray count] == 0)
    {
        self.listTableView.backgroundView = noDataPlaceholder;
    }
    else
    {
        self.listTableView.backgroundView = nil;
    }
}

-(IBAction)menuButtonDidClick:(id)sender
{
    if(!self.myTabBarController)
    {
        self.myTabBarController = (MyTabBarController *)self.tabBarController;
    }
    [self.myTabBarController showSlideMenuController];
}

#pragma mark - MonthPicker

-(MonthPickerViewController *)monthPickerViewController
{
    if(!_monthPickerViewController)
    {
        _monthPickerViewController = [[MonthPickerViewController alloc] initWithNibName:MonthPickerViewControllerNibName bundle:nil];
    }
    
    return _monthPickerViewController;
}

-(void)initMonthPickerButton
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy年"];
    NSString *year = [formatter stringFromDate:[NSDate date]];
    [formatter setDateFormat:@"MM月"];
    NSString *month = [formatter stringFromDate:[NSDate date]];
    
    //初始化月份选择按钮标题为当前年月
    [self.monthPickerButton setTitle:[NSString stringWithFormat:@"%@%@",year,month] forState:UIControlStateNormal];
    //设置一个展开图标
    UIImage *expandArrow = [UIImage imageNamed:@"ExpandArrow"];
    [self.monthPickerButton setImage:expandArrow forState:UIControlStateNormal];
    //计算按钮标题的宽度
    CGFloat labelWidth = [self.monthPickerButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15]}].width;
    //设置边距使UIButton的文字在左，图片在右
    [self.monthPickerButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -expandArrow.size.width, 0, expandArrow.size.width)];
    [self.monthPickerButton setImageEdgeInsets:UIEdgeInsetsMake(0,labelWidth, 0, -labelWidth)];
}

- (IBAction)monthPickerButtonDidClick:(id)sender {
    //设置代理和当前年月
    self.monthPickerViewController.delegate = self;
    self.monthPickerViewController.currentYearAndMonth = self.monthPickerButton.titleLabel.text;
    //显示月份选择器，将MonthPickerViewController嵌入到根视图控制器（侧栏效果器）
    [self.monthPickerViewController presentInParentViewController:[UIApplication sharedApplication].delegate.window.rootViewController];
}

#pragma mark - MonthPickerViewController Delegate

-(void)monthPickerViewController:(MonthPickerViewController *)controller chooseMonthAndYear:(NSString *)yearAndMonth
{
    //设置选中的年月为月份选择标题
    [self.monthPickerButton setTitle:[NSString stringWithFormat:@"%@",yearAndMonth] forState:UIControlStateNormal];
}

-(void)addDataModelToTableView:(CostItem *)dataModel
{
    [self.dataModelArray addObject:dataModel];
    [self.listTableView reloadData];
}

-(NSMutableArray *)dataModelArray
{
    if(!_dataModelArray)
    {
        _dataModelArray = [[NSMutableArray alloc] initWithCapacity:20];
    }
    
    return _dataModelArray;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataModelArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CostItem *dataModel = self.dataModelArray[indexPath.row];   //获取数据模型
    
    if((dataModel.comment == nil) || ([dataModel.comment isEqualToString:@""]))
    {
        ListCell *cell = (ListCell *)[tableView dequeueReusableCellWithIdentifier:ListCellIdentifier];
        //图标
        cell.imageView.image = [UIImage imageNamed:dataModel.category];
        //支出金额
        NSNumber *money = dataModel.money;
        cell.number.text = [NSString stringWithFormat:@"%.2lf",[money doubleValue]];
        if([money doubleValue] < 0)
        {
            cell.number.textColor = [UIColor redColor];
        }
        else
        {
            cell.number.textColor = [UIColor greenColor];
        }
        //标题
        cell.title.text = dataModel.categoryName;
        //图片标识
        if(![dataModel hasPhoto]) cell.imageIndicate.hidden = YES;
        else    cell.imageIndicate.hidden = NO;
        
        return cell;
    }
    else
    {
        ListCommentCell *cell = (ListCommentCell *)[tableView dequeueReusableCellWithIdentifier:ListCommentCellIdentifier];
        //图标
        cell.imageView.image = [UIImage imageNamed:dataModel.category];
        //支出金额
        NSNumber *money = dataModel.money;
        cell.number.text = [NSString stringWithFormat:@"%.2lf",[money doubleValue]];
        if([money doubleValue] < 0)
        {
            cell.number.textColor = [UIColor redColor];
        }
        else
        {
            cell.number.textColor = [UIColor greenColor];
        }
        //标题
        cell.title.text = dataModel.categoryName;
        //图片标识
        if(![dataModel hasPhoto]) cell.imageIndicate.hidden = YES;
        else    cell.imageIndicate.hidden = NO;
        //备注
        cell.comment.text = dataModel.comment;
        return cell;
    }
    
}



@end
