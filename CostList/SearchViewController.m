//
//  SearchViewController.m
//  CostList
//
//  Created by 许德鸿 on 2016/10/16.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "SearchViewController.h"
#import "ListCommentCell.h"
#import "MyTabBarController.h"
#import "MyNavigationController.h"
#import "AddItemViewController.h"

#define TableRowSeparatorColor [UIColor colorWithRed:216/255.0f green:216/255.0f blue:216/255.0f alpha:0.7]

static NSString *ListCommentCellIdentifier = @"ListCommentCell";

@interface SearchViewController () <UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SearchViewController
{
    NSMutableArray *_results;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.x = SCREEN_WIDTH;
    //去除多余的空行和分割线
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.isVisible = YES;
    //从右滑出的动画
    [UIView animateWithDuration:0.3 animations:^{
        self.view.x = 0;
    } completion:^(BOOL finished){
        if(_results.count==0)[self.searchBar becomeFirstResponder];
    }];
    
    if(self.searchBar.text.length != 0)
    {
        [self searchData];
    }
}

- (IBAction)cancelBtnClick:(id)sender {
        self.isVisible = NO;
    [self.searchBar resignFirstResponder];
    //由左向右滑走
    [UIView animateWithDuration:0.3 animations:^{
        self.view.x = SCREEN_WIDTH;
    } completion:^(BOOL finished){
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];
}

-(void)textWhetherHasData
{
    [self.tableView reloadData];
    UIImageView *noDataPlaceholder = [self.view viewWithTag:505];
    if(noDataPlaceholder != nil)
    {
        [noDataPlaceholder removeFromSuperview];    //若已有占位图则去除
    }
    if((_results.count == 0) || (_results == nil))
    {
        //没有数据时显示占位图
        noDataPlaceholder = [[UIImageView alloc] initWithFrame:CGRectMake(self.tableView.x, self.tableView.y,SCREEN_WIDTH,0)];
        noDataPlaceholder.tag = 505;
        UIImage *noDataImage = [UIImage imageNamed:@"NoDataImage2"];
        noDataPlaceholder.image = noDataImage;
        [noDataPlaceholder sizeToFit];
        [self.view addSubview:noDataPlaceholder];
    }
}

-(void)searchData
{
    [self.searchBar resignFirstResponder];
    _results = [[self.dataModelHandler searchDataByText:self.searchBar.text] mutableCopy];
    [self textWhetherHasData];
}

#pragma mark - UISearchBar Delegate
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self searchData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CostItem *dataModel = _results[indexPath.row];   //获取数据模型
    
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
    
    //添加分割线
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(15,self.tableView.rowHeight - 1,SCREEN_WIDTH - 15, 1)];
    separator.backgroundColor = TableRowSeparatorColor;
    [cell.contentView addSubview:separator];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    //滑动删除cell，并同步到CoreData数据库
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        __block NSMutableArray *array = _results;
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"警告", @"警告") message:NSLocalizedString(@"确定要删除该记录吗？（删除后的数据不可恢复）",@"确定要删除该记录吗？（删除后的数据不可恢复）") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sureBtn = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", @"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
            CostItem *data = _results[indexPath.row];
            if([self.dataModelHandler deleteData:data])
            {
                [array removeObject:data];
                [self textWhetherHasData];
            }
        }];
        UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", @"取消") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
        [controller addAction:cancelBtn];
        [controller addAction:sureBtn];
        [self presentViewController:controller animated:YES completion:nil];
    }
}

#pragma mark Table View Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyTabBarController *tabBarController = (MyTabBarController *)ROOT_VIEW_CONTROLLER;
    MyNavigationController *editNavigationController = [tabBarController getAddItemViewControllerToPreViewForDataModel:_results[indexPath.row]];
    AddItemViewController *controller = (AddItemViewController *)editNavigationController.topViewController;
    controller.delegate = tabBarController;
    controller.dataModelHandler = self.dataModelHandler;
    [self presentViewController:editNavigationController animated:YES completion:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
