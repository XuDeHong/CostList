//
//  MonthPickerViewController.m
//  CostList
//
//  Created by 许德鸿 on 16/8/12.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "MonthPickerViewController.h"

@interface MonthPickerViewController ()

@property (weak, nonatomic) IBOutlet UIView *separator1View; //横向分割线
@property (weak, nonatomic) IBOutlet UIView *separator2View; //纵向分割线

@end

@implementation MonthPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self customizeAppearence];
}

-(void)customizeAppearence
{
    //设置月份选择器全局tint color颜色
    self.view.tintColor = GlobalTintColor;
    
    //设置两条分割线的颜色
    self.separator1View.backgroundColor=self.separator2View.backgroundColor=GlobalTintColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
    }
    
    return self;
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
