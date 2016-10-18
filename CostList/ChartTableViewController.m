//
//  ChartTableViewController.m
//  CostList
//
//  Created by 许德鸿 on 16/8/8.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "ChartTableViewController.h"
#import "MonthPickerViewController.h"
#import "MyTabBarController.h"
#import "CostList-Swift.h"
#import "Charts/Charts.h"
#import "NSNumber+Category.h"
#import "UIColor+Category.h"
#import "YearPickerViewController.h"
#import "MonthValueFormatter.h"

static NSString *ChartCellIdentifier = @"ChartCell";
static NSString *LineListCellIdentifier = @"LineListCell";

@interface ChartTableViewController () <MonthPickerViewControllerDelegate,ChartViewDelegate,YearPickerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *upBackgroundView; //指向界面上部的视图，用于设置背景色
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong,nonatomic) MonthPickerViewController *monthPickerViewController;
@property (weak,nonatomic) MyTabBarController *myTabBarController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) IBOutlet PieChartView *pieChartView;
@property (nonatomic,strong) IBOutlet LineChartView *lineChartView;
@property (nonatomic,strong) IBOutlet UIView *separator;
@property (weak, nonatomic) IBOutlet UIButton *yearPickerButton;
@property (strong,nonatomic) YearPickerViewController *yearPickerViewController;
@property (weak, nonatomic) IBOutlet UIButton *incomeBtnForLine; //折线图的收入按钮
@property (weak, nonatomic) IBOutlet UIButton *spendBtnForLine; //折线图的支出按钮
@property (weak, nonatomic) IBOutlet UITableView *lineTableView;
@property (weak, nonatomic) IBOutlet UIView *lineListHeader;


@end

@implementation ChartTableViewController
{
    NSArray *_costItems;    //所有账目数据
    NSArray *_spendItems;   //所有支出的数据
    NSArray *_incomeItems;  //所有收入的数据
    NSArray *_spendTypes;   //所有支出的类型（不重复）
    NSArray *_incomeTypes;  //所有收入的类型（不重复）
    NSArray *_sortedSpendTypes; //所有支出的类型（不重复，排序）
    NSArray *_sortedIncomeTypes;    //所有收入的类型（不重复，排序）
    NSMutableArray *_totalSpendMoneyForEveryType;  //每一种支出类型的总支出（没排序）
    NSMutableArray *_totalIncomeMoneyForEveryType; //每一种收入类型的总收入（没排序）
    NSArray *_sortedtotalSpendMoneyForEveryType;  //每一种支出类型的总支出（排序）
    NSArray *_sortedtotalIncomeMoneyForEveryType; //每一种收入类型的总收入（排序）
    NSNumber *_totalSpendMoney; //总支出
    NSNumber *_totalIncomeMoney;  //总收入
    NSMutableArray *_spendMoneyPercentToTotalForEveryType;  //每一种支出类型的支出占总支出的百分比（没排序）
    NSMutableArray *_incomeMoneyPercentToTotalForEveryType;  //每一种收入类型的收入占总收入的百分比（没排序）
    NSArray *_sortedSpendPercentForEveryType;   //每一种支出类型的支出占总支出的百分比（排序）
    NSArray *_sortedIncomePercentForEveryType;  //每一种收入类型的收入占总收入的百分比（排序）
    NSDictionary *_spendTypeAndMoneys;  //每种类型的支出类型与金额
    NSDictionary *_incomeTypeAndMoneys; //每种类型的收入类型与金额
    
    NSMutableArray *_sortedSpendIconArray;  //每种支出类型对应的图标
    NSMutableArray *_sortedIncomeIconArray; //每种收入类型对应的图标
    NSMutableArray *_sortedSpendIconColors; //每种支出类型对应的图标的颜色
    NSMutableArray *_sortedIncomeIconColors; //每种收入类型对应的图标的颜色
    
    NSArray *_spendInfoArray;   //支出图标信息数组
    NSArray *_incomeInfoArray;  //收入图标信息数组
    
    BOOL _isSpendDataPrint;     //记录支出数据是否显示
    
    NSMutableArray *_everyMonthSpend;   //每月的总支出
    NSMutableArray *_everyMonthIncome;  //每月的总收入
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self customizeAppearence]; //设置UI元素
    
    [self initMonthPickerButton]; //初始化月份选择器按钮
    [self initYearPickerButton];    //初始化年份选择器按钮
    
    //去除多余的空行和分割线
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.lineTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //从plist文件读取类别Icon信息
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"CategoryIconInfo" ofType:@"plist"];
    NSDictionary *categoryIconInfo = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    _spendInfoArray = categoryIconInfo[@"spendArray"];
    _incomeInfoArray = categoryIconInfo[@"incomeArray"];
    
    _isSpendDataPrint = YES;
    
    [self setupPieChartView:self.pieChartView];     //设置饼图
    
    [self setupLineChartView:self.lineChartView];   //设置折线图
    
    //设置折线图里的收入按钮
    [self.incomeBtnForLine setImage:[UIImage imageNamed:@"incomeBtn"] forState:UIControlStateNormal];
    [self.incomeBtnForLine setImage:[UIImage imageNamed:@"incomeBtn"] forState:UIControlStateHighlighted];
    [self.incomeBtnForLine setImage:[UIImage imageNamed:@"incomeBtn-selected"] forState:UIControlStateSelected];
    [self.incomeBtnForLine setImage:[UIImage imageNamed:@"incomeBtn-selected"] forState:UIControlStateSelected | UIControlStateHighlighted];
    self.incomeBtnForLine.selected = YES;
    //设置折线图里的支出按钮
    [self.spendBtnForLine setImage:[UIImage imageNamed:@"spendBtn"] forState:UIControlStateNormal];
    [self.spendBtnForLine setImage:[UIImage imageNamed:@"spendBtn"] forState:UIControlStateHighlighted];
    [self.spendBtnForLine setImage:[UIImage imageNamed:@"spendBtn-selected"] forState:UIControlStateSelected];
    [self.spendBtnForLine setImage:[UIImage imageNamed:@"spendBtn-selected"] forState:UIControlStateSelected | UIControlStateHighlighted];
    self.spendBtnForLine.selected = YES;
}


-(void)customizeAppearence
{
    //设置界面上部的View的背景色
    self.upBackgroundView.backgroundColor = GLOBAL_TINT_COLOR;
    
    //设置NavigationBarItem的颜色
    self.navigationBar.tintColor = [UIColor whiteColor];
    
    //设置导航栏的backgroundView为透明（去除NavigationBar下部的横线和导航栏背景透明）
    if ([self.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
    {
        NSArray *list=self.navigationBar.subviews;
        for (id obj in list)
        {
            if ([obj isKindOfClass:[UIView class]] && (![obj isKindOfClass:[UIControl class]]))
            {
                UIView *background = (UIView *)obj;
                background.hidden = YES;
                break;
            }
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.pieChartView.hidden == NO)  [self fetchDataAndUpdateView];  //抓取数据和更新饼图
    else [self updateLineChartView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)menuButtonDidClick:(id)sender
{
    if(!self.myTabBarController)
    {
        self.myTabBarController = (MyTabBarController *)self.tabBarController;
    }
    [self.myTabBarController showSlideMenuController];
}
- (IBAction)switchChartView:(UISegmentedControl *)sender {
    //切换饼图和折线图
    if(self.pieChartView.hidden == NO)
    {
        self.pieChartView.hidden = YES;
        self.tableView.hidden = YES;
        self.lineChartView.hidden = NO; //显示折线图
        self.lineListHeader.hidden = NO;
        self.lineTableView.hidden = NO;
        self.incomeBtnForLine.hidden = NO;
        self.spendBtnForLine.hidden = NO;
        [self updateLineChartView];
        
        //去掉饼图中间的按钮
        if([self.view viewWithTag:5005] != nil)
        {
            [[self.view viewWithTag:5005] removeFromSuperview];
        }
        
        UIImageView *noDataPlaceholder = [self.view viewWithTag:505];
        if(noDataPlaceholder != nil)
        {
            [noDataPlaceholder removeFromSuperview];    //若已有占位图则去除
        }
        self.separator.hidden = NO;    //显示分割线
        
        self.yearPickerButton.hidden = NO;
        self.monthPickerButton.hidden = YES;
    }
    else
    {
        self.pieChartView.hidden = NO;  //显示圆饼图
        self.tableView.hidden = NO;
        self.lineChartView.hidden = YES;
        self.lineListHeader.hidden = YES;
        self.lineTableView.hidden = YES;
        self.incomeBtnForLine.hidden = YES;
        self.spendBtnForLine.hidden = YES;
        
        [self fetchDataAndUpdateView];
        
        self.yearPickerButton.hidden = YES;
        self.monthPickerButton.hidden = NO;
    }
}

#pragma mark - YearPicker

-(void)initYearPickerButton
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy年"];
    NSString *year = [formatter stringFromDate:[NSDate date]];
    
    //初始化年份选择按钮标题为当前年份
    [self.yearPickerButton setTitle:[NSString stringWithFormat:@"%@",year] forState:UIControlStateNormal];
    //设置一个展开图标
    UIImage *expandArrow = [UIImage imageNamed:@"ExpandArrow"];
    [self.yearPickerButton setImage:expandArrow forState:UIControlStateNormal];
    //计算按钮标题的宽度
    CGFloat labelWidth = [self.yearPickerButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15]}].width;
    //设置边距使UIButton的文字在左，图片在右
    [self.yearPickerButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -expandArrow.size.width, 0, expandArrow.size.width)];
    [self.yearPickerButton setImageEdgeInsets:UIEdgeInsetsMake(0,labelWidth, 0, -labelWidth)];
}

-(YearPickerViewController *)yearPickerViewController
{
    if(!_yearPickerViewController)
    {
        _yearPickerViewController = [[YearPickerViewController alloc] initWithNibName:@"YearPickerViewController" bundle:nil];
    }
    
    return _yearPickerViewController;
}

- (IBAction)yearPickerBtnDidClick:(id)sender {
    //设置代理和当前年份
    self.yearPickerViewController.delegate = self;
    self.yearPickerViewController.currentYear = self.yearPickerButton.titleLabel.text;
    //显示月份选择器，将YearPickerViewController嵌入到根视图控制器（侧栏效果器）
    [self.yearPickerViewController presentInParentViewController:[UIApplication sharedApplication].delegate.window.rootViewController];
}

#pragma mark - YearPickerViewController Delegate

-(void)yearPickerViewController:(YearPickerViewController *)controller chooseYear:(NSString *)year
{
    //设置选中的年份为年份选择标题
    [self.yearPickerButton setTitle:[NSString stringWithFormat:@"%@",year] forState:UIControlStateNormal];
    [self updateLineChartView];
}


#pragma mark - Line Chart Methods

- (IBAction)incomeBtnClick:(UIButton *)sender {
    if((sender.isSelected == YES) && (self.spendBtnForLine.isSelected == NO))
    {
        return; //防止收入和支出同时取消
    }
    
    sender.selected = !sender.selected;
    
    self.lineChartView.data = nil;
    [self setDataCount:(int)_everyMonthSpend.count];    //更新折线图
    [self.lineChartView animateWithXAxisDuration:0];
}

- (IBAction)spendBtnClick:(UIButton *)sender {
    if((sender.isSelected == YES) && (self.incomeBtnForLine.isSelected == NO))
    {
        return; //防止收入和支出同时取消
    }
    
    sender.selected = !sender.selected;
    self.lineChartView.data = nil;
    [self setDataCount:(int)_everyMonthSpend.count];    //更新折线图
    [self.lineChartView animateWithXAxisDuration:0];
}


-(void)setupLineChartView:(LineChartView *)chartView
{
    chartView.delegate = self;
    chartView.chartDescription.enabled = NO;
    chartView.dragEnabled = NO;
    [chartView setScaleEnabled:NO];
    chartView.legend.enabled = NO;
    chartView.rightAxis.enabled = NO;
    chartView.highlightPerTapEnabled = NO;

    ChartXAxis *xAxis = chartView.xAxis;
    xAxis.labelTextColor = [UIColor grayColor];
    xAxis.drawGridLinesEnabled = NO;
    xAxis.drawAxisLineEnabled = YES;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.valueFormatter = [[MonthValueFormatter alloc] init];
    
    ChartYAxis *leftAxis = chartView.leftAxis;
    leftAxis.labelTextColor = [UIColor grayColor];
    //leftAxis.axisMaximum = 999999999.99;
    //leftAxis.axisMinimum = 0.0;
    leftAxis.drawGridLinesEnabled = YES;
    leftAxis.drawZeroLineEnabled = NO;
    leftAxis.granularityEnabled = YES;
    leftAxis.gridLineDashLengths = @[@10,@10];
    leftAxis.gridColor = [UIColor colorWithRed:216/255.0f green:216/255.0f blue:216/255.0f alpha:1];

}

-(void)updateLineChartView
{
    self.lineChartView.data = nil;
    
    NSString *year = [[self.yearPickerButton titleForState:UIControlStateNormal] substringWithRange:NSMakeRange(0, 4)];
    
    [self getDataForLineChartWitchYear:year];
    
    double maxSpendNum = [[_everyMonthSpend valueForKeyPath:@"@max.doubleValue"] doubleValue];
    double maxIncomeNum = [[_everyMonthIncome valueForKeyPath:@"@max.doubleValue"] doubleValue];
    if(maxSpendNum > maxIncomeNum)
    {
        self.lineChartView.leftAxis.axisMaximum = maxSpendNum + maxSpendNum/2;
    }
    else if(maxIncomeNum > maxSpendNum)
    {
        self.lineChartView.leftAxis.axisMaximum = maxIncomeNum + maxIncomeNum/2;
    }
    else
    {
        if(maxSpendNum != 0)
        {
            self.lineChartView.leftAxis.axisMaximum = maxSpendNum + maxSpendNum/2;
        }
        else
        {
            //这里全年收入和支出都为0，应该显示空数据
            self.lineChartView.leftAxis.axisMaximum = 900;
        }
    }
    
    [self setDataCount:(int)_everyMonthSpend.count];
    
    [self.lineTableView reloadData];
    
    [self.lineChartView animateWithXAxisDuration:0.5];
}

- (void)setDataCount:(int)count
{
    NSMutableArray *yVals1 = [[NSMutableArray alloc] init];
    NSMutableArray *yVals2 = [[NSMutableArray alloc] init];
    
    for (int i = 1; i <= count; i++)
    {
        [yVals1 addObject:[[ChartDataEntry alloc] initWithX:i y:[_everyMonthSpend[i-1] doubleValue]]];
        [yVals2 addObject:[[ChartDataEntry alloc] initWithX:i y:[_everyMonthIncome[i-1] doubleValue]]];
    }
    
    LineChartDataSet *set1 = nil;
    LineChartDataSet *set2 = nil;
    
    if (self.lineChartView.data.dataSetCount > 0)
    {
        if(self.spendBtnForLine.isSelected == YES)
        {
            set1 = (LineChartDataSet *)self.lineChartView.data.dataSets[0];
            set1.values = yVals1;
        }
        if(self.incomeBtnForLine.isSelected == YES)
        {
            set2 = (LineChartDataSet *)self.lineChartView.data.dataSets[1];
            set2.values = yVals2;
        }
        [self.lineChartView.data notifyDataChanged];
        [self.lineChartView notifyDataSetChanged];
    }
    else
    {
        NSMutableArray *dataSets = [[NSMutableArray alloc] init];
        
        if(self.spendBtnForLine.isSelected == YES)
        {
            set1 = [[LineChartDataSet alloc] initWithValues:yVals1 label:@"DataSet 1"];
            set1.axisDependency = AxisDependencyLeft;
            [set1 setColor:[UIColor colorWithRed:237/255.f green:75/255.f blue:19/255.f alpha:1.f]];
            [set1 setCircleColor:[UIColor colorWithRed:237/255.f green:75/255.f blue:19/255.f alpha:1.f]];
            set1.lineWidth = 2.0;
            set1.circleRadius = 3.0;
            set1.fillAlpha = 65/255.0;
            set1.fillColor = [UIColor colorWithRed:237/255.f green:75/255.f blue:19/255.f alpha:1.f];
            //set1.highlightColor = [UIColor colorWithRed:244/255.f green:117/255.f blue:117/255.f alpha:1.f];
            set1.drawCircleHoleEnabled = NO;
            set1.drawValuesEnabled = NO;
            [dataSets addObject:set1];
        }
        
        if(self.incomeBtnForLine.isSelected == YES)
        {
            set2 = [[LineChartDataSet alloc] initWithValues:yVals2 label:@"DataSet 2"];
            set2.axisDependency = AxisDependencyLeft;
            [set2 setColor:[UIColor colorWithRed:4/255.f green:223/255.f blue:140/255.f alpha:1.f]];
            [set2 setCircleColor:[UIColor colorWithRed:4/255.f green:223/255.f blue:140/255.f alpha:1.f]];
            set2.lineWidth = 2.0;
            set2.circleRadius = 3.0;
            set2.fillAlpha = 65/255.0;
            set2.fillColor = [UIColor colorWithRed:4/255.f green:223/255.f blue:140/255.f alpha:1.f];
            //set2.highlightColor = [UIColor colorWithRed:244/255.f green:117/255.f blue:117/255.f alpha:1.f];
            set2.drawCircleHoleEnabled = NO;
            set2.drawValuesEnabled = NO;
            [dataSets addObject:set2];
        }
        
        LineChartData *data = [[LineChartData alloc] initWithDataSets:dataSets];
        [data setValueTextColor:UIColor.whiteColor];
        [data setValueFont:[UIFont systemFontOfSize:9.f]];
        
        self.lineChartView.data = data;
    }
}

-(void)getDataForLineChartWitchYear:(NSString *)year
{
    _everyMonthSpend = [NSMutableArray array];  //初始化数组
    _everyMonthIncome = [NSMutableArray array];  //初始化数组
    
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *currentYear = [formatter stringFromDate:date];
    
    if([year isEqualToString:currentYear])  //如果选择显示今年，则只显示到当前月份，后面月份不显示
    {
        [formatter setDateFormat:@"MM"];
        NSString *currentMonth = [formatter stringFromDate:date];
        
        for(int i = 1;i <= [currentMonth intValue];i++)
        {
            NSString *month = [NSString stringWithFormat:@"%02d",i];
            NSArray *theMonthData = [self fetchDataForYear:year andMonth:month];    //获得该月所有支出和收入数据
            
            if(theMonthData == nil)
            {
                [self calculateTotalMoneyForMonth:nil];
            }
            else
            {
                [self calculateTotalMoneyForMonth:theMonthData];
            }
        }
    }
    else    //以前的年份则显示12个月份
    {
        for(int i = 1;i < 13;i++)
        {
            NSString *month = [NSString stringWithFormat:@"%02d",i];
            NSArray *theMonthData = [self fetchDataForYear:year andMonth:month];    //获得该月所有支出和收入数据
            
            if(theMonthData == nil)
            {
                [self calculateTotalMoneyForMonth:nil];
            }
            else
            {
                [self calculateTotalMoneyForMonth:theMonthData];
            }
        }
    }
}

-(NSArray *)fetchDataForYear:(NSString *)year andMonth:(NSString *)month
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CostItem" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];

    NSString *nextMonth = nil;
    NSDate *startDate = nil;
    NSDate *endDate = nil;
    if([month intValue] == 12)
    {
        nextMonth = @"01";
        NSString *nextYear = [NSString stringWithFormat:@"%d",[year intValue] + 1];
        
        startDate = [formatter dateFromString:[NSString stringWithFormat:@"%@-%@-01",year,month]];
        endDate = [formatter dateFromString:[NSString stringWithFormat:@"%@-%@-01",nextYear,nextMonth]];
    }
    else
    {
        nextMonth = [NSString stringWithFormat:@"%d",[month intValue] + 1];
        
        startDate = [formatter dateFromString:[NSString stringWithFormat:@"%@-%@-01",year,month]];
        endDate = [formatter dateFromString:[NSString stringWithFormat:@"%@-%@-01",year,nextMonth]];
    }

    //设置过滤器，设置获取特定月份的数据
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(date >= %@) AND (date < %@)",startDate,endDate];
    
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *foundObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if((foundObjects == nil) || (foundObjects.count == 0))    //从CoreData中获取数据
    {
        return nil;
    }
    else
    {
        return foundObjects;
    }
}

-(void)calculateTotalMoneyForMonth:(NSArray *)theMonthData
{
    if(theMonthData == nil)
    {
        [_everyMonthSpend addObject:@0];
        [_everyMonthIncome addObject:@0];
    }
    else
    {
        NSPredicate *incomePredicate = [NSPredicate predicateWithFormat:@"money > %@",@0];
        NSArray *incomeArray = [theMonthData filteredArrayUsingPredicate:incomePredicate];    //过滤出所有收入的数据
        if((incomeArray != nil) && (incomeArray.count != 0))
        {
            NSNumber *totalIncomeMoney = [incomeArray valueForKeyPath:@"@sum.money"];   //计算总收入
            [_everyMonthIncome addObject:totalIncomeMoney];
        }
        else
        {
            [_everyMonthIncome addObject:@0];
        }
        
        NSPredicate *spendPredicate = [NSPredicate predicateWithFormat:@"money < %@",@0];
        NSArray *spendArray = [theMonthData filteredArrayUsingPredicate:spendPredicate];    //过滤出所有支出的数据
        if((spendArray != nil) && (spendArray.count != 0))
        {
            NSNumber *totalSpendMoney = [spendArray valueForKeyPath:@"@sum.money"];   //计算总支出
            [_everyMonthSpend addObject:@(-[totalSpendMoney doubleValue])];
        }
        else
        {
            [_everyMonthSpend addObject:@0];
        }
    }
}

#pragma mark - Pie Chart Methods

- (void)setupPieChartView:(PieChartView *)chartView
{
    chartView.drawSlicesUnderHoleEnabled = NO;
    chartView.holeRadiusPercent = 0.58;     //饼图内圆半径占大圆半径的百分比
    chartView.transparentCircleRadiusPercent = 0.61;    //猜测是透明度
    chartView.chartDescription.enabled = NO;    //图表描述
    [chartView setExtraOffsetsWithLeft:5.f top:10.f right:5.f bottom:5.f];  //间隔
    
    chartView.drawCenterTextEnabled = YES;  //显示中心文本
    chartView.drawHoleEnabled = YES;    //饼图中间空心
    chartView.rotationAngle = 0.0;  //旋转一个角度
    chartView.rotationEnabled = NO; //不能手动旋转
    chartView.highlightPerTapEnabled = NO;  //图表不能点击
    chartView.delegate = self;  //代理
    chartView.legend.enabled = NO;  //不显示图例
}

-(void)switchPrintedData
{
    if(_isSpendDataPrint)   _isSpendDataPrint = NO;
    else    _isSpendDataPrint = YES;
    
    [self.tableView reloadData];  //保证数据最新
    [self textWhetherHasData];  //测试是否有数据，没有数据则显示占位图，有数据则更新统计图
}


-(void)setDataForPieChart
{
    if(_isSpendDataPrint)
    {
        if((_spendItems != nil) && (_spendItems.count != 0))
        {
            [self updatePieChar:_sortedtotalSpendMoneyForEveryType iconColors:_sortedSpendIconColors totalMoney:_totalSpendMoney];      //显示支出数据
        }
        else
        {
            [self updatePieChar:@[@1] iconColors:@[@"9B9B9B"] totalMoney:0];    //没有支出数据
            //隐藏分割线
            self.separator.hidden = YES;
        }
    }
    else
    {
        if((_incomeItems != nil) && (_incomeItems.count != 0))
        {
            [self updatePieChar:_sortedtotalIncomeMoneyForEveryType iconColors:_sortedIncomeIconColors totalMoney:_totalIncomeMoney];   //显示收入数据
        }
        else
        {
            [self updatePieChar:@[@1] iconColors:@[@"9B9B9B"] totalMoney:0];    //没有收入数据
            //隐藏分割线
            self.separator.hidden = YES;
        }
    }
    

}

-(void)updatePieChar:(NSArray *)totalMoneyArray iconColors:(NSArray *)iconColors totalMoney:(NSNumber *)totalMoney
{
    //获取数据
    NSMutableArray *values = [[NSMutableArray alloc] init];
    for(int i = 0;i < totalMoneyArray.count;i++)
    {
        [values addObject:[[PieChartDataEntry alloc] initWithValue:[totalMoneyArray[i] doubleValue]]];
    }
    
    PieChartDataSet *dataSet = [[PieChartDataSet alloc] initWithValues:values label:nil];
    
    //获取各数据对应的颜色
    NSMutableArray *colors = [NSMutableArray array];
    for(NSString *str in iconColors)
    {
        [colors addObject:[UIColor colorWithHexString:str]];
    }
    dataSet.colors = colors;
    
    dataSet.drawValuesEnabled = NO; //不显示各扇区的数据
    
    PieChartData *data = [[PieChartData alloc] initWithDataSet:dataSet];
    self.pieChartView.data = data;
    
    //段落格式
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByClipping;   //猜测是超出一行则截断
    paragraphStyle.alignment = NSTextAlignmentCenter;   //文本居中
    
    //获取总金额
    NSString *money = [NSString stringWithFormat:@"%.2lf",[totalMoney doubleValue]];
    //设置饼图中间的文本
    NSMutableAttributedString *centerText = nil;
    if(_isSpendDataPrint)
    {
        centerText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"总支出\n%@\n⇋",money]];
    }
    else
    {
        centerText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"总收入\n%@\n⇋",money]];
    }
    //金额数字的格式
    [centerText setAttributes:@{
                                NSFontAttributeName: [UIFont boldSystemFontOfSize:16.0f],
                                NSParagraphStyleAttributeName: paragraphStyle
                                } range:NSMakeRange(0,centerText.length)];
    //“总支出”或“总收入”的文本格式
    [centerText addAttributes:@{
                                NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:12.f],
                                NSForegroundColorAttributeName:UIColor.grayColor
                                } range:NSMakeRange(0,3)];
    //最后一个双向箭头⇋的格式
    [centerText addAttributes:@{
                                NSFontAttributeName: [UIFont boldSystemFontOfSize:22.0f],
                                NSForegroundColorAttributeName: [UIColor colorWithRed:51/255.f green:181/255.f blue:229/255.f alpha:1.f]
                                } range:NSMakeRange(money.length + 5,1)];
    self.pieChartView.centerAttributedText = centerText;
    
    //在饼图中间放置一个按钮用于切换收入比例图和支出比例图
    if(([self.view viewWithTag:5005] == nil) && (self.pieChartView.hidden == NO))
    {
        CGFloat radius = self.pieChartView.radius;  //饼图半径
        CGFloat holeRadius = radius * self.pieChartView.holeRadiusPercent;  //饼图内圆半径
        UIButton *tapBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, holeRadius * 2, holeRadius * 2)];
        CGPoint center = [self.pieChartView convertPoint:self.pieChartView.centerCircleBox toView:self.view];   //饼图中心位置
        tapBtn.center = center;
        tapBtn.tag = 5005;
        tapBtn.backgroundColor = [UIColor clearColor];
        [self.view addSubview:tapBtn];
        
        [tapBtn addTarget:self action:@selector(switchPrintedData) forControlEvents:UIControlEventTouchUpInside];   //添加触发方法
    }
}

#pragma mark - About Fetch and Handle Data

-(void)textWhetherHasData
{
    UIImageView *noDataPlaceholder = [self.view viewWithTag:505];
    if(noDataPlaceholder != nil)
    {
        [noDataPlaceholder removeFromSuperview];    //若已有占位图则去除
    }
    
    if((_costItems == nil) || (_costItems.count == 0))
    {
        //没有数据时显示占位图
        noDataPlaceholder = [[UIImageView alloc] initWithFrame:CGRectMake(self.pieChartView.x, self.pieChartView.y,self.pieChartView.width,self.pieChartView.height)];
        noDataPlaceholder.tag = 505;
        UIImage *noDataImage = [UIImage imageNamed:@"NoDataImage2"];
        noDataPlaceholder.image = noDataImage;
        [self.view addSubview:noDataPlaceholder];
        
        //隐藏分割线
        self.separator.hidden = YES;
        
        self.pieChartView.data = nil;
    }
    else
    {
        //显示分割线
        self.separator.hidden = NO;
        
        [self setDataForPieChart];  //提供数据给饼图
        
        [self.pieChartView animateWithXAxisDuration:0.5 easingOption:ChartEasingOptionLinear];  //产生饼图动画
    }
}

-(void)fetchDataAndUpdateView
{
    [self setNilToSomeArrays];   //抓取数据前先清空所有数组
    [self performFetch]; //从CoreData中获取数据
    [self.tableView reloadData];  //保证数据最新
    [self textWhetherHasData];  //测试是否有数据，没有数据则显示占位图，有数据则更新统计图
}

-(void)performFetch
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CostItem" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *year = [[self.monthPickerButton titleForState:UIControlStateNormal] substringWithRange:NSMakeRange(0, 4)];
    NSString *month = [[self.monthPickerButton titleForState:UIControlStateNormal] substringWithRange:NSMakeRange(5, 2)];
    
    NSString *nextMonth = nil;
    NSDate *startDate = nil;
    NSDate *endDate = nil;
    if([month intValue] == 12)
    {
        nextMonth = @"01";
        NSString *nextYear = [NSString stringWithFormat:@"%d",[year intValue] + 1];
        
        startDate = [formatter dateFromString:[NSString stringWithFormat:@"%@-%@-01",year,month]];
        endDate = [formatter dateFromString:[NSString stringWithFormat:@"%@-%@-01",nextYear,nextMonth]];
    }
    else
    {
        nextMonth = [NSString stringWithFormat:@"%d",[month intValue] + 1];
        
        startDate = [formatter dateFromString:[NSString stringWithFormat:@"%@-%@-01",year,month]];
        endDate = [formatter dateFromString:[NSString stringWithFormat:@"%@-%@-01",year,nextMonth]];
    }
    
    //设置过滤器，设置显示当前月份选择器显示的年月的记录
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(date >= %@) AND (date < %@)",startDate,endDate];
    
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *foundObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(foundObjects == nil)    //从CoreData中获取数据
    {
        [self setNilToSomeArrays];  //将实例变量的数组置空
        FATAL_CORE_DATA_ERROR(error);
        return;
    }
    if(foundObjects.count == 0)
    {
        [self setNilToSomeArrays];  //将实例变量的数组置空
        return;
    }
    _costItems = foundObjects;
    
    [self handleData];  //处理获取的所有数据
}

-(void)setNilToSomeArrays
{
    _costItems = nil;
    _spendItems = nil;
    _incomeItems = nil;
    _spendTypes = nil;
    _incomeTypes = nil;
    _sortedSpendTypes = nil;
    _sortedIncomeTypes = nil;
    _totalSpendMoneyForEveryType = nil;
    _totalIncomeMoneyForEveryType = nil;
    _sortedtotalSpendMoneyForEveryType = nil;
    _sortedtotalIncomeMoneyForEveryType = nil;
    _totalSpendMoney = nil;
    _totalIncomeMoney = nil;
    _spendMoneyPercentToTotalForEveryType = nil;
    _incomeMoneyPercentToTotalForEveryType = nil;
    _sortedSpendPercentForEveryType = nil;
    _sortedIncomePercentForEveryType = nil;
    _spendTypeAndMoneys = nil;
    _incomeTypeAndMoneys = nil;
    
    _sortedSpendIconArray = nil;
    _sortedIncomeIconArray = nil;
    _sortedSpendIconColors = nil;
    _sortedIncomeIconColors = nil;
}

-(void)handleData
{
    if((_costItems != nil) && (_costItems.count != 0))
    {
        [self handleIncomeData];    //处理收入的数据
        [self handleSpendData];     //处理支出的数据
    }
}

-(void)handleIncomeData
{
    NSPredicate *incomePredicate = [NSPredicate predicateWithFormat:@"money > %@",@0];
    _incomeItems = [_costItems filteredArrayUsingPredicate:incomePredicate];    //过滤出所有收入的数据
    if((_incomeItems != nil) && (_incomeItems.count != 0))
    {
        _totalIncomeMoney = [_incomeItems valueForKeyPath:@"@sum.money"];   //计算总收入
        _incomeTypes = [_incomeItems valueForKeyPath:@"@distinctUnionOfObjects.categoryName"];  //获得所有收入类型
        _totalIncomeMoneyForEveryType = [NSMutableArray array]; //初始化数组
        _incomeMoneyPercentToTotalForEveryType = [NSMutableArray array];    //初始化数组
        _sortedIncomeIconArray = [NSMutableArray array];    //初始化数组
        _sortedIncomeIconColors = [NSMutableArray array];   //初始化数组
        NSMutableArray *tmpTypes = [NSMutableArray array];  //新建一个临时数组来存放所有收入类型
        for(NSString *type in _incomeTypes)
        {
            NSArray *array = [_incomeItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"categoryName == %@",type]];   //将收入中同一类别的数据筛选出来
            double totalMoneyInOneType = 0;
            
            for(CostItem *item in array)    //将收入中同一类型的数据的金额相加，即计算该类型的总收入
            {
                totalMoneyInOneType += [item.money doubleValue];
            }
            //将该类型的总收入加入到数组
            [_totalIncomeMoneyForEveryType addObject:[NSNumber numberWithDouble:totalMoneyInOneType]];
            //将类型加入到数组
            [tmpTypes addObject:type];
            //计算该类型的收入占总收入的百分比
            NSNumber *percent = @([[NSString stringWithFormat:@"%.2f",totalMoneyInOneType/[_totalIncomeMoney doubleValue]*100 ]doubleValue]);
            //将百分比加入到数组
            [_incomeMoneyPercentToTotalForEveryType addObject:percent];
        }
        //使用NSDictionary是为了让收入类型与该类型的总收入联系起来，键为收入类型，值为该类型总收入，方便排序类型
        _incomeTypeAndMoneys = [NSDictionary dictionaryWithObjects:[_totalIncomeMoneyForEveryType copy] forKeys:[tmpTypes copy]];
        //按照收入高低对收入类型进行降序排列
        _sortedIncomeTypes = [_incomeTypeAndMoneys keysSortedByValueUsingSelector:@selector(doubleCompare:)];
        //降序排列每种类型的总收入
        _sortedtotalIncomeMoneyForEveryType = [_totalIncomeMoneyForEveryType sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:nil ascending:NO]]];
        //降序排列每种类型的总收入百分比
        _sortedIncomePercentForEveryType = [_incomeMoneyPercentToTotalForEveryType sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:nil ascending:NO]]];
        
        //显示总收入
        //NSLog(@"totalIncomeMoney %@",_totalIncomeMoney);
        for(NSString *type in _sortedIncomeTypes)
        {
            //NSLog(@"type :%@",type);    //降序显示类型
            //降序显示金额，或者换成_sortedtotalIncomeMoneyForEveryType
            //NSNumber *money = _incomeTypeAndMoneys[type];
            //NSLog(@"money :%@",money);
            
            for (NSDictionary *dict in _incomeInfoArray)
            {
                if([[dict objectForKey:@"DisplayName"] isEqualToString:type])
                {
                    //获取类别对应的图标标识
                    [_sortedIncomeIconArray addObject:[dict objectForKey:@"IconName"]];
                    //NSLog(@"%@",[dict objectForKey:@"IconName"]);
                    //获取类别对应的图标颜色
                    [_sortedIncomeIconColors addObject:[dict objectForKey:@"BGColor"]];
                    //NSLog(@"%@",[dict objectForKey:@"BGColor"]);
                    break;
                }
            }
        }
        //NSLog(@"%@",_sortedIncomePercentForEveryType);  //降序显示百分比
    }
}

-(void)handleSpendData
{
    NSPredicate *spendPredicate = [NSPredicate predicateWithFormat:@"money < %@",@0];
    _spendItems = [_costItems filteredArrayUsingPredicate:spendPredicate];    //过滤出所有支出的数据
    if((_spendItems != nil) && (_spendItems.count != 0))
    {
        _totalSpendMoney = [_spendItems valueForKeyPath:@"@sum.money"];   //计算总支出
        _totalSpendMoney = @(-[_totalSpendMoney doubleValue]);
        _spendTypes = [_spendItems valueForKeyPath:@"@distinctUnionOfObjects.categoryName"];  //获得所有支出类型
        _totalSpendMoneyForEveryType = [NSMutableArray array]; //初始化数组
        _spendMoneyPercentToTotalForEveryType = [NSMutableArray array];    //初始化数组
        _sortedSpendIconArray = [NSMutableArray array];    //初始化数组
        _sortedSpendIconColors = [NSMutableArray array];    //初始化数组
        NSMutableArray *tmpTypes = [NSMutableArray array];  //新建一个临时数组来存放所有支出类型
        for(NSString *type in _spendTypes)
        {
            NSArray *array = [_spendItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"categoryName == %@",type]];   //将支出中同一类别的数据筛选出来
            double totalMoneyInOneType = 0;
            
            for(CostItem *item in array)    //将支出中同一类型的数据的金额相加，即计算该类型的总支出
            {
                totalMoneyInOneType += [item.money doubleValue];
            }
            totalMoneyInOneType = -totalMoneyInOneType;
            //将该类型的总支出加入到数组
            [_totalSpendMoneyForEveryType addObject:[NSNumber numberWithDouble:totalMoneyInOneType]];
            //将类型加入到数组
            [tmpTypes addObject:type];
            //计算该类型的支出占总支出的百分比
            NSNumber *percent = @([[NSString stringWithFormat:@"%.2f",totalMoneyInOneType/[_totalSpendMoney doubleValue]*100 ]doubleValue]);
            //将百分比加入到数组
            [_spendMoneyPercentToTotalForEveryType addObject:percent];
        }
        //使用NSDictionary是为了让支出类型与该类型的总支出联系起来，键为支出类型，值为该类型总支出，方便排序类型
        _spendTypeAndMoneys = [NSDictionary dictionaryWithObjects:[_totalSpendMoneyForEveryType copy] forKeys:[tmpTypes copy]];
        //按照支出高低对支出类型进行降序排列
        _sortedSpendTypes = [_spendTypeAndMoneys keysSortedByValueUsingSelector:@selector(doubleCompare:)];
        //降序排列每种类型的总支出
        _sortedtotalSpendMoneyForEveryType = [_totalSpendMoneyForEveryType sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:nil ascending:NO]]];
        //降序排列每种类型的总支出百分比
        _sortedSpendPercentForEveryType = [_spendMoneyPercentToTotalForEveryType sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:nil ascending:NO]]];
        
        //显示总支出
        //NSLog(@"totalSpendMoney %@",_totalSpendMoney);
        for(NSString *type in _sortedSpendTypes)
        {
            //NSLog(@"type :%@",type);    //降序显示类型
            //降序显示金额，或者换成_sortedtotalSpendMoneyForEveryType
            //NSNumber *money = _spendTypeAndMoneys[type];
            //NSLog(@"money :%@",money);
            
            for (NSDictionary *dict in _spendInfoArray)
            {
                if([[dict objectForKey:@"DisplayName"] isEqualToString:type])
                {
                    //获取类别对应的图标标识
                    [_sortedSpendIconArray addObject:[dict objectForKey:@"IconName"]];
                    //NSLog(@"%@",[dict objectForKey:@"IconName"]);
                    //获取类别对应的图标颜色
                    [_sortedSpendIconColors addObject:[dict objectForKey:@"BGColor"]];
                    //NSLog(@"%@",[dict objectForKey:@"BGColor"]);
                    break;
                }
            }
        }
        //NSLog(@"%@",_sortedSpendPercentForEveryType);  //降序显示百分比
    }
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
    [self fetchDataAndUpdateView];  //抓取数据和更新视图
}


#pragma mark - Table View data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([tableView isEqual:self.tableView])
    {
        if(_isSpendDataPrint)
            return _sortedSpendTypes.count;
        else
            return _sortedIncomeTypes.count;
    }
    else
    {
        return _everyMonthSpend.count + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([tableView isEqual:self.tableView])
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ChartCellIdentifier];
        if(_isSpendDataPrint)
        {
            UIImage *icon = [UIImage imageNamed:_sortedSpendIconArray[indexPath.row]];
            cell.imageView.image = icon;
            UILabel *iconNameLabel = [cell viewWithTag:1001];
            iconNameLabel.text = _sortedSpendTypes[indexPath.row];
            [iconNameLabel sizeToFit];
            UILabel *percentLabel = [cell viewWithTag:1002];
            percentLabel.text = [NSString stringWithFormat:@"%.2lf%%",[_sortedSpendPercentForEveryType[indexPath.row] doubleValue]];
            [percentLabel sizeToFit];
            UILabel *moneyLabel = [cell viewWithTag:1003];
            moneyLabel.text = [NSString stringWithFormat:@"%.2lf",[_sortedtotalSpendMoneyForEveryType[indexPath.row]doubleValue]];
            [moneyLabel sizeToFit];
        }
        else
        {
            UIImage *icon = [UIImage imageNamed:_sortedIncomeIconArray[indexPath.row]];
            cell.imageView.image = icon;
            UILabel *iconNameLabel = [cell viewWithTag:1001];
            iconNameLabel.text = _sortedIncomeTypes[indexPath.row];
            [iconNameLabel sizeToFit];
            UILabel *percentLabel = [cell viewWithTag:1002];
            percentLabel.text = [NSString stringWithFormat:@"%.2lf%%",[_sortedIncomePercentForEveryType[indexPath.row] doubleValue]];
            [percentLabel sizeToFit];
            UILabel *moneyLabel = [cell viewWithTag:1003];
            moneyLabel.text = [NSString stringWithFormat:@"%.2lf",[_sortedtotalIncomeMoneyForEveryType[indexPath.row]doubleValue]];
            [moneyLabel sizeToFit];
        }
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LineListCellIdentifier];
        UILabel *monthlabel = [cell viewWithTag:2001];
        UILabel *incomeLabel = [cell viewWithTag:2002];
        UILabel *spendLabel = [cell viewWithTag:2003];
        UILabel *surplusLabel = [cell viewWithTag:2004];    //结余标签
        double surplus = 0;
        
        if(indexPath.row != _everyMonthSpend.count)
        {
            monthlabel.text = [NSString stringWithFormat:@"%02ld月",indexPath.row + 1];

            incomeLabel.text = [NSString stringWithFormat:@"%.2lf",[_everyMonthIncome[indexPath.row] doubleValue]];

            spendLabel.text = [NSString stringWithFormat:@"%.2lf",[_everyMonthSpend[indexPath.row] doubleValue]];

            surplus = [_everyMonthIncome[indexPath.row] doubleValue] - [_everyMonthSpend[indexPath.row] doubleValue];    //计算结余
        }
        else    //添加最后一行合计
        {
            monthlabel.text = NSLocalizedString(@"合计", @"合计");
            double totalSpend = [[_everyMonthSpend valueForKeyPath:@"@sum.doubleValue"] doubleValue];
            double totalIncome = [[_everyMonthIncome valueForKeyPath:@"@sum.doubleValue"] doubleValue];
            incomeLabel.text = [NSString stringWithFormat:@"%.2lf",totalIncome];
            spendLabel.text = [NSString stringWithFormat:@"%.2lf",totalSpend];
            surplus = totalIncome - totalSpend;
        }
        
        
        surplusLabel.text = [NSString stringWithFormat:@"%.2lf",surplus];
        [monthlabel sizeToFit];
        [incomeLabel sizeToFit];
        [spendLabel sizeToFit];
        [surplusLabel sizeToFit];
        if(surplus > 0)
        {
            
            surplusLabel.textColor = [UIColor greenColor];
        }
        else if(surplus < 0)
        {
            surplusLabel.textColor = [UIColor redColor];
        }
        else
        {
            surplusLabel.textColor = [UIColor lightGrayColor];
        }
        
        return cell;
    }
}

#pragma mark Table View Delegate
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil; //圆饼图和折线图的TableView的行均不能点击
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
