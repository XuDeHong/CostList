//
//  SearchViewController.m
//  CostList
//
//  Created by 许德鸿 on 2016/10/16.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController () <UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation SearchViewController
{
    NSArray *_results;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.x = SCREEN_WIDTH;
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
    
    NSLog(@"%ld",_results.count);
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
