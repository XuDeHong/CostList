//
//  SearchViewController.m
//  CostList
//
//  Created by 许德鸿 on 2016/10/16.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "SearchViewController.h"
#import "ListCommentCell.h"

#define TableRowSeparatorColor [UIColor colorWithRed:216/255.0f green:216/255.0f blue:216/255.0f alpha:0.7]

static NSString *ListCommentCellIdentifier = @"ListCommentCell";

@interface SearchViewController () <UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SearchViewController
{
    NSArray *_results;
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
    //从右滑出的动画
    [UIView animateWithDuration:0.3 animations:^{
        self.view.x = 0;
    } completion:^(BOOL finished){
        [self.searchBar becomeFirstResponder];
    }];
}

- (IBAction)cancelBtnClick:(id)sender {
    [self.searchBar resignFirstResponder];
    self.isVisible = NO;
    //由左向右滑走
    [UIView animateWithDuration:0.3 animations:^{
        self.view.x = SCREEN_WIDTH;
    } completion:^(BOOL finished){
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];
}

-(void)searchDataForText:(NSString *)string
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CostItem" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    //设置过滤器
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"comment CONTAINS %@",string];
    
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *foundObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if((foundObjects == nil) || (foundObjects.count == 0))    //从CoreData中获取数据
    {
        _results = nil;
    }
    else
    {
        _results = foundObjects;
    }
}

#pragma mark - UISearchBar Delegate
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    [self searchDataForText:searchBar.text];
    [self.tableView reloadData];
    //NSLog(@"%ld",_results.count);
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



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
