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

#define TableViewSectionTitleViewBackgroundColor [UIColor colorWithRed:216/255.0f green:216/255.0f blue:216/255.0f alpha:0.2]
#define TableViewSectionHeight 28


static NSString *ListCellIdentifier = @"ListCell";
static NSString *ListCommentCellIdentifier = @"ListCommentCell";

@interface ListTableViewController () <MonthPickerViewControllerDelegate,NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *upBackgroundView;  //指向界面上部的视图，用于设置背景色
@property (weak,nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong,nonatomic) MonthPickerViewController *monthPickerViewController;
@property (weak,nonatomic) MyTabBarController *myTabBarController;
@property (weak, nonatomic) IBOutlet UITableView *listTableView;

@end

@implementation ListTableViewController
{
    NSFetchedResultsController *_fetchedResultsController;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self customizeAppearence]; //设置UI元素
    
    //去除多余的空行和分割线
    self.listTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self initMonthPickerButton]; //初始化月份选择器按钮
    
    [self performFetch]; //从CoreData中获取数据
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

-(void)dealloc
{
    _fetchedResultsController.delegate = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self textWhetherHasData];  //测试是否有数据，没有数据则显示占位图
    //[self.listTableView reloadData];
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

-(IBAction)menuButtonDidClick:(id)sender
{
    if(!self.myTabBarController)
    {
        self.myTabBarController = (MyTabBarController *)self.tabBarController;
    }
    [self.myTabBarController showSlideMenuController];
}

#pragma mark - About NSFetchedResults(Controller) Methods

-(NSFetchedResultsController *)fetchedResultsController
{
    if(_fetchedResultsController == nil)
    {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        //设置数据实体
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"CostItem" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
        //NSSortDescriptor *sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
        [fetchRequest setSortDescriptors:@[sortDescriptor1]];
        //设置一次获取的数据量
        [fetchRequest setFetchBatchSize:20];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"date" cacheName:@"CostItems"];
        //设置代理
        _fetchedResultsController.delegate = self;
    }
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
    [self.monthPickerViewController presentInParentViewController:[UIApplication sharedApplication].delegate.window.rootViewController];
}

#pragma mark - MonthPickerViewController Delegate

-(void)monthPickerViewController:(MonthPickerViewController *)controller chooseMonthAndYear:(NSString *)yearAndMonth
{
    //设置选中的年月为月份选择标题
    [self.monthPickerButton setTitle:[NSString stringWithFormat:@"%@",yearAndMonth] forState:UIControlStateNormal];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count]; //利用NSFetchedResultsController来获取行数
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

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tableView.bounds.size.width,TableViewSectionHeight)];
    view.backgroundColor = TableViewSectionTitleViewBackgroundColor;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15.0f,0.0f, 300.0f, 14.0f)];
    label.centerY = view.centerY;
    label.font = [UIFont boldSystemFontOfSize:11.0f];
    label.text = [tableView.dataSource tableView:tableView titleForHeaderInSection:section];
    label.textColor = [UIColor colorWithWhite:0 alpha:0.3];
    label.backgroundColor = [UIColor clearColor];
    
    [view addSubview:label];
    
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
        if(![dataModel hasPhoto]) cell.imageIndicate.hidden = YES;
        else    cell.imageIndicate.hidden = NO;
        
        [self configureSeparatorForCell:cell atIndexPath:indexPath];    //设置分割线
        
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
        
        [self configureSeparatorForCell:cell atIndexPath:indexPath];    //设置分割线
        
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
        separator.hidden = YES;
    
    //当cell不是最后一组并且是该组最后一行是不需要添加分割线，其他情况就需要添加
    if(!((indexPath.section != maxSection) && (indexPath.row == maxRowInSec)))
    {
        separator.hidden = NO;
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    //滑动删除cell，并同步到CoreData数据库
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"警告" message:@"确定要删除该记录吗？（删除后的数据不可恢复）" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sureBtn = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
                CostItem *dataModel = [self.fetchedResultsController objectAtIndexPath:indexPath];   //获取数据模型
                [dataModel removePhotoFile];    //删除图片
                [self.managedObjectContext deleteObject:dataModel];
            
                NSError *error;
                if(![self.managedObjectContext save:&error])
                {
                    FATAL_CORE_DATA_ERROR(error);
                    return;
                }
        }];
        UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self.listTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
        [controller addAction:cancelBtn];
        [controller addAction:sureBtn];
        [self presentViewController:controller animated:YES completion:nil];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"*** controllerWillChangeContent");
    [self.listTableView beginUpdates];
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(nonnull id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            NSLog(@"*** NSFetchedResultsChangeInsert (object)");
            [self.listTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            NSLog(@"*** NSFetchedResultsChangeDelete (object)");
            [self.listTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            NSLog(@"*** NSFetchedResultsChangeUpdate (object)");
            //修改cell
            //[self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        case NSFetchedResultsChangeMove:
            NSLog(@"*** NSFetchedResultsChangeMove (object)");
            [self.listTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.listTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

-(void)controller:(NSFetchedResultsController *)controller didChangeSection:(nonnull id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            NSLog(@"*** NSFetchedResultsChangeInsert (section)");
            [self.listTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            NSLog(@"*** NSFetchedResultsChangeDelete (section)");
            [self.listTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:    break;
        case NSFetchedResultsChangeUpdate:  break;
            
    }
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"*** controllerDidChangeContent");
    [self.listTableView endUpdates];
    [self textWhetherHasData];  //测试是否有数据，没有数据则显示占位图
    //[self.listTableView reloadData];
}

@end

