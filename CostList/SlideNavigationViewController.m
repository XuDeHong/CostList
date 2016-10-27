//
//  SlideNavigationViewController.m
//  CostList
//
//  Created by 许德鸿 on 2016/10/26.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "SlideNavigationViewController.h"

@interface SlideNavigationViewController ()

@end

@implementation SlideNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.x = 0 - SCREEN_WIDTH;
    self.isVisible = YES;
    self.navigationBar.tintColor = GLOBAL_TINT_COLOR;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //从左滑出的动画
    [UIView animateWithDuration:0.3 animations:^{
        self.view.x = 0;
    } completion:nil];
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
