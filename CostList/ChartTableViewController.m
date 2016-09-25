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

static NSString *ChartCellIdentifier = @"ChartCell";

@interface ChartTableViewController () <MonthPickerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *upBackgroundView; //指向界面上部的视图，用于设置背景色
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong,nonatomic) MonthPickerViewController *monthPickerViewController;
@property (weak,nonatomic) MyTabBarController *myTabBarController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) IBOutlet PieChartView *pieChartView;
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
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self customizeAppearence]; //设置UI元素
    
    [self initMonthPickerButton]; //初始化月份选择器按钮
    
    //去除多余的空行和分割线
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //从plist文件读取类别Icon信息
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"CategoryIconInfo" ofType:@"plist"];
    NSDictionary *categoryIconInfo = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    _spendInfoArray = categoryIconInfo[@"spendArray"];
    _incomeInfoArray = categoryIconInfo[@"incomeArray"];
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
    
    [self fetchDataAndUpdateView];  //抓取数据和更新视图
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

-(void)textWhetherHasData
{
    UIImageView *noDataPlaceholder = [self.view viewWithTag:505];
    if(noDataPlaceholder != nil)
    {
        [noDataPlaceholder removeFromSuperview];    //若已有占位图则去除
    }
    
    if([_costItems count] == 0)
    {
        //没有数据时的占位图
        noDataPlaceholder = [[UIImageView alloc] initWithFrame:CGRectMake(self.pieChartView.x, self.pieChartView.y,self.pieChartView.width,self.pieChartView.height)];
        noDataPlaceholder.tag = 505;
        UIImage *noDataImage = [UIImage imageNamed:@"NoDataImage2"];
        noDataPlaceholder.image = noDataImage;
        [self.view addSubview:noDataPlaceholder];
        self.pieChartView.centerText = @"";
    }
}

-(void)fetchDataAndUpdateView
{
    [self performFetch]; //从CoreData中获取数据
    [self.tableView reloadData];  //保证数据最新
    [self textWhetherHasData];  //测试是否有数据，没有数据则显示占位图
}

-(void)performFetch
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CostItem" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSString *year = [[self.monthPickerButton titleForState:UIControlStateNormal] substringWithRange:NSMakeRange(0, 4)];
    NSString *month = [[self.monthPickerButton titleForState:UIControlStateNormal] substringWithRange:NSMakeRange(5, 2)];
    NSString *nextMonth = [NSString stringWithFormat:@"%d",[month intValue] + 1];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *startDate = [formatter dateFromString:[NSString stringWithFormat:@"%@-%@-01",year,month]];
    NSDate *endDate = [formatter dateFromString:[NSString stringWithFormat:@"%@-%@-01",year,nextMonth]];
    
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
    if(_costItems != nil)
    {
        [self handleIncomeData];
        [self handleSpendData];
    }
}

-(void)handleIncomeData
{
    NSPredicate *incomePredicate = [NSPredicate predicateWithFormat:@"money > %@",@0];
    _incomeItems = [_costItems filteredArrayUsingPredicate:incomePredicate];    //过滤出所有收入的数据
    _totalIncomeMoney = [_incomeItems valueForKeyPath:@"@sum.money"];   //计算总收入
    _incomeTypes = [_incomeItems valueForKeyPath:@"@distinctUnionOfObjects.categoryName"];  //获得所有收入类型
    _totalIncomeMoneyForEveryType = [NSMutableArray array]; //初始化数组
    _incomeMoneyPercentToTotalForEveryType = [NSMutableArray array];    //初始化数组
    _sortedIncomeIconArray = [NSMutableArray array];    //初始化数组
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
    NSLog(@"totalIncomeMoney %@",_totalIncomeMoney);
    for(NSString *type in _sortedIncomeTypes)
    {
        NSLog(@"type :%@",type);    //降序显示类型
        //降序显示金额，或者换成_sortedtotalIncomeMoneyForEveryType
        NSNumber *money = _incomeTypeAndMoneys[type];
        NSLog(@"money :%@",money);
        
        for (NSDictionary *dict in _incomeInfoArray)
        {
            if([[dict objectForKey:@"DisplayName"] isEqualToString:type])
            {
                //获取类别对应的图标标识
                [_sortedIncomeIconArray addObject:[dict objectForKey:@"IconName"]];
                NSLog(@"%@",[dict objectForKey:@"IconName"]);
                //获取类别对应的图标颜色
                [_sortedIncomeIconColors addObject:[dict objectForKey:@"BGColor"]];
                NSLog(@"%@",[dict objectForKey:@"BGColor"]);
                break;
            }
        }
    }
    NSLog(@"%@",_sortedIncomePercentForEveryType);  //降序显示百分比
}

-(void)handleSpendData
{
    NSPredicate *spendPredicate = [NSPredicate predicateWithFormat:@"money < %@",@0];
    _spendItems = [_costItems filteredArrayUsingPredicate:spendPredicate];    //过滤出所有支出的数据
    _totalSpendMoney = [_spendItems valueForKeyPath:@"@sum.money"];   //计算总支出
    _totalSpendMoney = @(-[_totalSpendMoney doubleValue]);
    _spendTypes = [_spendItems valueForKeyPath:@"@distinctUnionOfObjects.categoryName"];  //获得所有支出类型
    _totalSpendMoneyForEveryType = [NSMutableArray array]; //初始化数组
    _spendMoneyPercentToTotalForEveryType = [NSMutableArray array];    //初始化数组
    _sortedSpendIconArray = [NSMutableArray array];    //初始化数组
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
    NSLog(@"totalSpendMoney %@",_totalSpendMoney);
    for(NSString *type in _sortedSpendTypes)
    {
        NSLog(@"type :%@",type);    //降序显示类型
        //降序显示金额，或者换成_sortedtotalSpendMoneyForEveryType
        NSNumber *money = _spendTypeAndMoneys[type];
        NSLog(@"money :%@",money);
        
        for (NSDictionary *dict in _spendInfoArray)
        {
            if([[dict objectForKey:@"DisplayName"] isEqualToString:type])
            {
                //获取类别对应的图标标识
                [_sortedSpendIconArray addObject:[dict objectForKey:@"IconName"]];
                NSLog(@"%@",[dict objectForKey:@"IconName"]);
                //获取类别对应的图标颜色
                [_sortedSpendIconColors addObject:[dict objectForKey:@"BGColor"]];
                NSLog(@"%@",[dict objectForKey:@"BGColor"]);
                break;
            }
        }
    }
    NSLog(@"%@",_sortedSpendPercentForEveryType);  //降序显示百分比
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sortedIncomeTypes.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ChartCellIdentifier];
    UIImage *icon = [UIImage imageNamed:_sortedIncomeIconArray[indexPath.row]];
    cell.imageView.image = icon;
    UILabel *iconNameLabel = [cell viewWithTag:1001];
    iconNameLabel.text = _sortedIncomeTypes[indexPath.row];
    [iconNameLabel sizeToFit];
    UILabel *percentLabel = [cell viewWithTag:1002];
    percentLabel.text = [NSString stringWithFormat:@"%.2lf%%",[_sortedIncomePercentForEveryType[indexPath.row] doubleValue]];
    [percentLabel sizeToFit];
    UILabel *moneyLabel = [cell viewWithTag:1003];
    moneyLabel.text = [NSString stringWithFormat:@"%@",_sortedtotalIncomeMoneyForEveryType[indexPath.row]];
    [moneyLabel sizeToFit];
    
    return cell;
}



@end
