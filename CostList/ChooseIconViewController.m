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
    _incomeArray = @[];
}

- (IBAction)segmentedControlChange:(id)sender {
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
        image = [UIImage imageNamed:[dict objectForKey:@"IconName"]];  //设置图标
        cell.imageView.image = image;
        cell.textLabel.text = [dict objectForKey:@"DisplayName"];   //设置名称
    }
    else
    {
        dict = _incomeArray[indexPath.row];
        image = [UIImage imageNamed:[dict objectForKey:@"IconName"]];  //设置图标
        cell.imageView.image = image;
        cell.textLabel.text = [dict objectForKey:@"DisplayName"];   //设置名称
    }
    
    return cell;
}

#pragma mark TableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
