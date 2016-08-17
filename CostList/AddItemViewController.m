//
//  AddItemViewController.m
//  CostList
//
//  Created by 许德鸿 on 16/8/17.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "AddItemViewController.h"

@implementation AddItemViewController 

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //去除多余的空行和分割线
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (IBAction)cancelButtonClick:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)saveButtonClick:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
 
 // Configure the cell...
 
 return cell;
 }
 */

@end
