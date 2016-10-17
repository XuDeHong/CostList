//
//  SearchViewController.m
//  CostList
//
//  Created by 许德鸿 on 2016/10/16.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation SearchViewController

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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
