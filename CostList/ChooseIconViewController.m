//
//  ChooseIconViewController.m
//  CostList
//
//  Created by 许德鸿 on 16/8/17.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "ChooseIconViewController.h"

#define CellImageViewWidth 30   //图标宽度
#define CellImageViewHeight 30  //图标高度

static NSString *CostCategoryCellIdentifier = @"CostCategoryCell";

@interface ChooseIconViewController() <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ChooseIconViewController
{
    NSArray *_spendArray;
    NSArray *_incomeArray;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    //初始化数组
    _spendArray = @[@{@"IconName":@"travel",    @"DisplayName":@"旅行"},
                   @{@"IconName":@"traffic",    @"DisplayName":@"交通"},
                   @{@"IconName":@"eat",        @"DisplayName":@"吃饭"},
                   @{@"IconName":@"shop",       @"DisplayName":@"购物"},
                   @{@"IconName":@"play",       @"DisplayName":@"娱乐"},
                   @{@"IconName":@"medical",    @"DisplayName":@"药品"},
                   @{@"IconName":@"rent",       @"DisplayName":@"房租"},
                   @{@"IconName":@"school",     @"DisplayName":@"教育"},
                   @{@"IconName":@"snack",      @"DisplayName":@"零食"},
                   @{@"IconName":@"taobao",     @"DisplayName":@"网购"},
                   @{@"IconName":@"clothes",    @"DisplayName":@"衣服"},
                   @{@"IconName":@"fruit",      @"DisplayName":@"水果"},
                   @{@"IconName":@"utilities",  @"DisplayName":@"水电费"},
                   @{@"IconName":@"daily",      @"DisplayName":@"日用品"},
                   @{@"IconName":@"cosmetic",   @"DisplayName":@"化妆品"},
                   @{@"IconName":@"other",      @"DisplayName":@"其他"}];
    
    _incomeArray = @[@{@"IconName":@"salary",      @"DisplayName":@"工资"},
                     @{@"IconName":@"bonus",      @"DisplayName":@"奖金"},
                     @{@"IconName":@"pocket money",      @"DisplayName":@"零花钱"},
                     @{@"IconName":@"investment",      @"DisplayName":@"投资"},
                     @{@"IconName":@"red packet",      @"DisplayName":@"红包"},
                     @{@"IconName":@"other",      @"DisplayName":@"其他"}];
    
    //去除多余的空行和分割线
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (IBAction)segmentedControlChange:(id)sender {
    //设置是否可滚动
    self.tableView.scrollEnabled = (self.segmentedControl.selectedSegmentIndex == 0) ? YES : NO;
    //更新tableview
    [self.tableView reloadData];
}


#pragma mark - TableView Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.segmentedControl.selectedSegmentIndex == 0)
    {
        return _spendArray.count;   //返回支出数组的数目
    }
    else
    {
        return _incomeArray.count;  //返回收入数组的数目
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CostCategoryCellIdentifier];
    NSDictionary *dict = nil;
    UIImage *image = nil;
    
    if(self.segmentedControl.selectedSegmentIndex == 0)
    {
        dict = _spendArray[indexPath.row];
    }
    else
    {
        dict = _incomeArray[indexPath.row];
    }
    image = [UIImage imageNamed:[dict objectForKey:@"IconName"]];  //设置图标
    cell.imageView.image = image;
    cell.textLabel.text = [dict objectForKey:@"DisplayName"];   //设置名称
    
    return cell;
}

#pragma mark TableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = nil;
    NSAttributedString *str = nil;
    
    if(self.segmentedControl.selectedSegmentIndex == 0)
    {
        dict = _spendArray[indexPath.row];
        str = [[NSAttributedString alloc] initWithString:[dict objectForKey:@"DisplayName"] attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];   //支出的字体设为红色
    }
    else
    {
        dict = _incomeArray[indexPath.row];
        str = [[NSAttributedString alloc] initWithString:[dict objectForKey:@"DisplayName"] attributes:@{NSForegroundColorAttributeName:[UIColor greenColor]}];     //收入的字体设为绿色
    }
    [self.delegate chooseIconViewController:self didChooseIcon:[dict objectForKey:@"IconName"] andDisplayName:str];
}

@end
