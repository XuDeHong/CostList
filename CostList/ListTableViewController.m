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
#import "MyNavigationController.h"
#import "SearchViewController.h"
#import "UIViewController+Category.h"

#define TableViewSectionTitleViewBackgroundColor [UIColor colorWithRed:216/255.0f green:216/255.0f blue:216/255.0f alpha:0.2]
#define TableViewSectionHeight 28
#define TableRowSeparatorColor [UIColor colorWithRed:216/255.0f green:216/255.0f blue:216/255.0f alpha:0.7]


static NSString *ListCellIdentifier = @"ListCell";
static NSString *ListCommentCellIdentifier = @"ListCommentCell";

@interface ListTableViewController () <MonthPickerViewControllerDelegate,NSFetchedResultsControllerDelegate,UIViewControllerPreviewingDelegate>

@property (weak, nonatomic) IBOutlet UIView *upBackgroundView;  //指向界面上部的视图，用于设置背景色
@property (weak,nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong,nonatomic) MonthPickerViewController *monthPickerViewController;
@property (weak,nonatomic) MyTabBarController *myTabBarController;
@property (weak, nonatomic) IBOutlet UITableView *listTableView;
@property (weak, nonatomic) IBOutlet UILabel *totalSpendLbl;
@property (weak, nonatomic) IBOutlet UILabel *totalIncomeLbl;

@end

@implementation ListTableViewController
{
    NSFetchedResultsController *_fetchedResultsController;
    BOOL _isFirstTime;
    
    NSMutableArray *_everyDayTotalSpend;
    NSMutableArray *_everyDayTotalIncome;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self customizeAppearence]; //设置UI元素
    
    [self initMonthPickerButton]; //初始化月份选择器按钮
    
    //去除多余的空行和分割线
    self.listTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    _isFirstTime = YES;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    _fetchedResultsController.delegate = nil;
}

-(void)fetchDataAndUpdateTableView
{
    [self performFetch]; //从CoreData中获取数据
    [self.listTableView reloadData];  //保证数据最新，并更新分割线显示问题
    [self textWhetherHasData];  //测试是否有数据，没有数据则显示占位图
    
    //以下代码更新该界面顶部的总收入和总支出
    NSArray *results = [self.fetchedResultsController fetchedObjects];
    if((results != nil) && (results.count != 0))
    {
        NSPredicate *incomePredicate = [NSPredicate predicateWithFormat:@"money > %@",@0];
        NSArray *incomeItems = [results filteredArrayUsingPredicate:incomePredicate];    //过滤出所有收入的数据
        if((incomeItems != nil) && (incomeItems.count != 0))
        {
            NSNumber *totalIncome = [incomeItems valueForKeyPath:@"@sum.money"];   //计算总收入
            self.totalIncomeLbl.text = [NSString stringWithFormat:@"%.2lf",[totalIncome doubleValue]];
        }
        else
        {
            self.totalIncomeLbl.text = NSLocalizedString(@"0.00", @"0.00");
        }
        
        NSPredicate *spendPredicate = [NSPredicate predicateWithFormat:@"money < %@",@0];
        NSArray *spendItems = [results filteredArrayUsingPredicate:spendPredicate];    //过滤出所有支出的数据
        if((spendItems != nil) && (spendItems.count != 0))
        {
            NSNumber *totalSpend = [spendItems valueForKeyPath:@"@sum.money"];   //计算总支出
            self.totalSpendLbl.text = [NSString stringWithFormat:@"%.2lf",[totalSpend doubleValue] * (-1)];
        }
        else
        {
            self.totalSpendLbl.text = NSLocalizedString(@"0.00", @"0.00");
        }
        
        [self calculateTotalMoneyForEveryDay:results];
    }
    else
    {
        self.totalIncomeLbl.text = NSLocalizedString(@"0.00", @"0.00");
        self.totalSpendLbl.text = NSLocalizedString(@"0.00", @"0.00");
        
        _everyDayTotalSpend = nil;
        _everyDayTotalIncome = nil;
    }

}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    if([self.presentedViewController isKindOfClass:[SearchViewController class]])
    {
        SearchViewController *searchController = (SearchViewController *)self.presentedViewController;
        if(searchController.isVisible)
        {
            return UIStatusBarStyleDefault; //将状态栏设为黑色
        }
        else
            return UIStatusBarStyleLightContent;
    }
    return UIStatusBarStyleLightContent;    //将状态栏设为白色
}

-(BOOL)prefersStatusBarHidden
{
    return NO;  //不隐藏状态栏
}

//计算当月每一日的总收入和总支出
-(void)calculateTotalMoneyForEveryDay:(NSArray *)results
{
    _everyDayTotalSpend = [NSMutableArray array];
    _everyDayTotalIncome = [NSMutableArray array];
    
    for(int i = 0 ; i < [self.fetchedResultsController sections].count ; i++)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][i];
        NSString *dateString = [sectionInfo name];
        
        //从日期字符串中获取日期对象
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZ"];
        NSDate *date = [formatter dateFromString:dateString];
        
        NSPredicate *dayPredicate = [NSPredicate predicateWithFormat:@"date == %@",date];
        NSArray *dayArray = [results filteredArrayUsingPredicate:dayPredicate];//获得该日所有数据
        if((dayArray != nil) && (dayArray.count != 0))
        {
            NSPredicate *spendPredicate = [NSPredicate predicateWithFormat:@"money < %@",@0];
            NSArray *spendItems = [dayArray filteredArrayUsingPredicate:spendPredicate];//过滤出该日支出数据
            if((spendItems != nil) && (spendItems.count != 0))
            {
                NSNumber *totalSpend = [spendItems valueForKeyPath:@"@sum.money"];   //计算当日总支出
                _everyDayTotalSpend[i] = @(-[totalSpend doubleValue]);
            }
            else
            {
                _everyDayTotalSpend[i] = @(0);
            }
            
            NSPredicate *incomePredicate = [NSPredicate predicateWithFormat:@"money > %@",@0];
            NSArray *incomeItems = [dayArray filteredArrayUsingPredicate:incomePredicate];  //过滤出该日收入数据
            if((incomeItems != nil) && (incomeItems.count != 0))
            {
                NSNumber *totalIncome = [incomeItems valueForKeyPath:@"@sum.money"];   //计算当日总收入
                _everyDayTotalIncome[i] = @([totalIncome doubleValue]);
            }
            else
            {
                _everyDayTotalIncome[i] = @(0);
            }
        }
        else
        {
            _everyDayTotalIncome[i] = @(0);
            _everyDayTotalSpend[i] = @(0);
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [NSFetchedResultsController deleteCacheWithName:@"CostItems"];  //删除缓存数据
    [self fetchDataAndUpdateTableView]; //抓取数据和更新TableView
    
    if(_isFirstTime)
    {
        _isFirstTime = NO;
        [self hideSeparatorAtFirstTime];
    }
}

-(void)hideSeparatorAtFirstTime
{
    int maxSection = (int)[self.fetchedResultsController sections].count;
    for(int i = 0;i< (maxSection - 1); i++)
    {
        id <NSFetchedResultsSectionInfo>sectionInfo = [self.fetchedResultsController sections][i];
        int maxRow = (int)[sectionInfo numberOfObjects] - 1;
        UITableViewCell *cell = [self.listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:maxRow inSection:i]];
        if(cell != nil)
        {
            UIView *separator = [cell viewWithTag:500];
            if(separator != nil)
            {
                separator.hidden = YES;
            }
        }
    }
}

-(void)textWhetherHasData
{
    //没有数据时的占位图
    UIImageView *noDataPlaceholder = [[UIImageView alloc] initWithFrame:CGRectMake(self.listTableView.x, self.listTableView.y, self.listTableView.width, self.listTableView.height)];
    UIImage *noDataImage = [UIImage imageNamed:@"NoDataImage"];
    noDataPlaceholder.image = noDataImage;
    
    if([[self.fetchedResultsController sections] count] == 0)
    {
        self.listTableView.backgroundView = noDataPlaceholder;  //没有数据时显示占位图
    }
    else
    {
        self.listTableView.backgroundView = nil;
    }
}

-(MyTabBarController *)myTabBarController
{
    if(!_myTabBarController)
    {
        _myTabBarController = (MyTabBarController *)self.tabBarController;
    }
    return _myTabBarController;
}

-(IBAction)menuButtonDidClick:(id)sender
{
    [self.myTabBarController showSlideMenuController];
}

- (IBAction)searchBtnDidClick:(id)sender
{
    SearchViewController *searchViewController = [SearchViewController instanceFromStoryboardV2];
    searchViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    searchViewController.dataModelHandler= self.dataModelHandler;
    [self presentViewController:searchViewController animated:NO completion:nil];
}

#pragma mark - About NSFetchedResults(Controller) Methods

-(NSFetchedResultsController *)fetchedResultsController
{
    if(_fetchedResultsController == nil)
    {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        //设置数据实体
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"CostItem" inManagedObjectContext:self.dataModelHandler.managedObjectContext];
        [fetchRequest setEntity:entity];
        //设置排序
        NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
        NSSortDescriptor *sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"createTime" ascending:NO];
        [fetchRequest setSortDescriptors:@[sortDescriptor1,sortDescriptor2]];
        //设置一次获取的数据量
        [fetchRequest setFetchBatchSize:20];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.dataModelHandler.managedObjectContext sectionNameKeyPath:@"date" cacheName:@"CostItems"];
        //设置代理
        _fetchedResultsController.delegate = self;
    }
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
    
    [_fetchedResultsController.fetchRequest setPredicate:predicate];
    
    return _fetchedResultsController;
}

-(void)performFetch
{
    NSError *error;
    if(![self.fetchedResultsController performFetch:&error])    //从CoreData中获取数据
    {
        FATAL_CORE_DATA_ERROR(error);
        return;
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
    [self.monthPickerViewController presentInParentViewController:self.myTabBarController];
}

#pragma mark - MonthPickerViewController Delegate

-(void)monthPickerViewController:(MonthPickerViewController *)controller chooseMonthAndYear:(NSString *)yearAndMonth
{
    //设置选中的年月为月份选择标题
    [self.monthPickerButton setTitle:[NSString stringWithFormat:@"%@",yearAndMonth] forState:UIControlStateNormal];
    [NSFetchedResultsController deleteCacheWithName:@"CostItems"];  //删除缓存数据
    [self fetchDataAndUpdateTableView]; //抓取数据和更新TableView
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count]; //利用NSFetchedResultsController来获取组数
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    NSString *dateString = [sectionInfo name];
    //从日期字符串中获取日期对象
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZ"];
    NSDate *date = [formatter dateFromString:dateString];
    //获取月份
    [formatter setDateFormat:@"MM月"];
    NSString *month = [formatter stringFromDate:date];
    
    //获取日期
    [formatter setDateFormat:@"dd日"];
    NSString *day = [formatter stringFromDate:date];
    
    return [NSString stringWithFormat:@"%@%@",month,day];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //利用NSFetchedResultsController来获取行数
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CostItem *dataModel = [self.fetchedResultsController objectAtIndexPath:indexPath];   //获取数据模型
    
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
        if(![dataModel hasPhoto])
            cell.imageIndicate.hidden = YES;
        else
            cell.imageIndicate.hidden = NO;
        
        [self configureSeparatorForCell:cell atIndexPath:indexPath];    //设置分割线
        //如果3D Touch可用，则注册cell为可按压
        if(self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable)
        {
            [self registerForPreviewingWithDelegate:self sourceView:cell];
        }
        
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
        if(![dataModel hasPhoto])
            cell.imageIndicate.hidden = YES;
        else
            cell.imageIndicate.hidden = NO;
        //备注
        cell.comment.text = dataModel.comment;
        
        [self configureSeparatorForCell:cell atIndexPath:indexPath];    //设置分割线
        //如果3D Touch可用，则注册cell为可按压
        if(self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable)
        {
            [self registerForPreviewingWithDelegate:self sourceView:cell];
        }
        
        return cell;
    }
}

-(void)configureSeparatorForCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][indexPath.section];
    //获取该组内最大行数
    int maxRowInSec = (int)[sectionInfo numberOfObjects] - 1;
    //获取最大组数
    int maxSection = (int)[[self.fetchedResultsController sections] count] - 1;
    
    //先看看是否有分割线，如果有的话先去掉
    UIView *separator = [cell viewWithTag:500];
    if(separator != nil)
    {
        //如果有分割线则先隐藏
        separator.hidden = YES;
    }
    else
    {
        //添加分割线
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(15,self.listTableView.rowHeight - 1,SCREEN_WIDTH - 15, 1)];
        separator.backgroundColor = TableRowSeparatorColor;
        separator.tag = 500;    //做一个标记，方便获取
        [cell.contentView addSubview:separator];
    }
    
    //当cell不是最后一组并且是该组最后一行是不需要添加分割线，其他情况就需要添加
    if(!((indexPath.section != maxSection) && (indexPath.row == maxRowInSec)))
    {
        separator.hidden = NO;
    }
    else
    {
        separator.hidden = YES;
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    //滑动删除cell，并同步到CoreData数据库
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self confirmDeleteDataAtIndexPath:indexPath];
    }
}

-(void)confirmDeleteDataAtIndexPath:(NSIndexPath *)indexPath
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"警告", @"警告") message:NSLocalizedString(@"确定要删除该记录吗？（删除后的数据不可恢复）",@"确定要删除该记录吗？（删除后的数据不可恢复）") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureBtn = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", @"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
        CostItem *dataModel = [self.fetchedResultsController objectAtIndexPath:indexPath];   //获取数据模型
        [self.dataModelHandler deleteData:dataModel];
    }];
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", @"取消") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self.listTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }];
    [controller addAction:cancelBtn];
    [controller addAction:sureBtn];
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark Table View Delegate

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tableView.bounds.size.width,TableViewSectionHeight)];
    view.backgroundColor = TableViewSectionTitleViewBackgroundColor;
    //每一组左边的日期
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15.0f,0.0f, 300.0f, 14.0f)];
    label.centerY = view.centerY;
    label.font = [UIFont systemFontOfSize:11.0f];
    label.text = [tableView.dataSource tableView:tableView titleForHeaderInSection:section];
    label.textColor = [UIColor colorWithWhite:0 alpha:0.3];
    label.backgroundColor = [UIColor clearColor];
    
    [view addSubview:label];
    
    //每一组右边的总支出和总收入
    UILabel *dayTotalLbl = [[UILabel alloc] initWithFrame:CGRectMake(15.0f,0.0f, 300.0f, 14.0f)];
    dayTotalLbl.centerY = view.centerY;
    dayTotalLbl.font = [UIFont systemFontOfSize:11.0f];
    double totalSpend = 0;
    double totalIncome = 0;
    if(_everyDayTotalSpend[section] != nil)
    {
        totalSpend = [_everyDayTotalSpend[section] doubleValue];
    }
    if(_everyDayTotalIncome[section] != nil)
    {
        totalIncome = [_everyDayTotalIncome[section] doubleValue];
    }
    dayTotalLbl.text = [NSString stringWithFormat:@"总收入：%.2lf 总支出：%.2lf",totalIncome,totalSpend];
    dayTotalLbl.textColor = [UIColor colorWithWhite:0 alpha:0.3];
    dayTotalLbl.backgroundColor = [UIColor clearColor];
    [dayTotalLbl sizeToFit];
    dayTotalLbl.x = tableView.bounds.size.width - dayTotalLbl.width - 10;   //使该标签与屏幕右边距间隔为10
    
    [view addSubview:dayTotalLbl];
    
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return TableViewSectionHeight;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN; //没有footer
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.myTabBarController showAddOrEditItemControllerWithDataModel:[self.fetchedResultsController objectAtIndexPath:indexPath]];     //传递数据模型，并显示编辑界面
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - NSFetchedResultsControllerDelegate

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.listTableView beginUpdates];
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(nonnull id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.listTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.listTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            //修改对应的cell，应该调用tableview的cellForRowAtIndexPath方法，但已经自动调用了，因为在viewWillAppear中刷新了tableview
            //[self configureSeparatorForCell:[self.listTableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        case NSFetchedResultsChangeMove:
            [self.listTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.listTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

-(void)controller:(NSFetchedResultsController *)controller didChangeSection:(nonnull id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.listTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.listTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:    break;
        case NSFetchedResultsChangeUpdate:  break;
            
    }
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.listTableView endUpdates];
    [self fetchDataAndUpdateTableView]; //抓取数据和更新TableView
}

#pragma mark - UIViewControllerPreviewing Delegate
-(nullable UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    //轻轻按压peek预览信息
    //获取按压的cell
    UITableViewCell *cell = (UITableViewCell *)[previewingContext sourceView];
    if ([cell isKindOfClass:[ListCell class]])
    {
        cell = (ListCell *)cell;
    } 
    else
    {
        cell = (ListCommentCell *)cell;
    }
    //获取cell的位置
    NSIndexPath *indexPath = [self.listTableView indexPathForCell:cell];
    //获取AddItemViewController
    MyNavigationController *preViewController = [self.myTabBarController getAddItemViewControllerToPreViewForDataModel:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    UIViewController *controller = preViewController.topViewController;
    //预览时删除导航栏两边的按钮
    UIBarButtonItem *leftBtn = controller.navigationItem.leftBarButtonItem;
    NSMutableArray *leftArray = [controller.navigationItem.leftBarButtonItems mutableCopy];
    [leftArray removeObject:leftBtn];
    controller.navigationItem.leftBarButtonItems = leftArray;
    
    UIBarButtonItem *rightBtn = controller.navigationItem.rightBarButtonItem;
    NSMutableArray *rightArray = [controller.navigationItem.rightBarButtonItems mutableCopy];
    [rightArray removeObject:rightBtn];
    controller.navigationItem.rightBarButtonItems = rightArray;
    
    preViewController.indexPathForData = indexPath;  //传递数据模型在TableView位置
    //调整不被虚化的范围，按压的那个cell不被虚化（轻轻按压时周边会被虚化，再少用力展示预览，再加力跳页至设定界面）
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width,self.listTableView.rowHeight);
    previewingContext.sourceRect = rect;
    
    [self.listTableView deselectRowAtIndexPath:indexPath animated:YES]; //取消cell的选中
    
    return (UIViewController *)preViewController;
}

-(void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    //在预览界面时加力重压，则POP出记录编辑页面
    //获取按压的cell
    UITableViewCell *cell = (UITableViewCell *)[previewingContext sourceView];
    if ([cell isKindOfClass:[ListCell class]])
    {
        cell = (ListCell *)cell;
    }
    else
    {
        cell = (ListCommentCell *)cell;
    }
    //获取cell的位置
    NSIndexPath *indexPath = [self.listTableView indexPathForCell:cell];
    [self.myTabBarController showAddOrEditItemControllerWithDataModel:[self.fetchedResultsController objectAtIndexPath:indexPath]];     //传递数据模型，并显示编辑界面
}
@end

