//
//  CyclePickerViewController.m
//  CostList
//
//  Created by 许德鸿 on 2017/3/19.
//  Copyright © 2017年 XuDeHong. All rights reserved.
//

#import "CyclePickerViewController.h"

@interface CyclePickerViewController () <UIPickerViewDelegate,UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UIPickerView *cyclePicker;

@end

@implementation CyclePickerViewController
{
    NSArray *_cycleItems;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _cycleItems = @[@"提醒一次",@"每天",@"每周",@"每月",@"每年"];
    
    //创建半透明黑色背景
    self.background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
    //设置周期选择器全局tint color颜色
    self.view.tintColor = GLOBAL_TINT_COLOR;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //设置和显示半透明黑色背景
    self.background.backgroundColor = [UIColor blackColor];
    self.background.alpha = 0.5;
    [self.presentingViewController.view addSubview:_background];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;    //将状态栏设为白色
}

-(BOOL)prefersStatusBarHidden
{
    return NO;  //不隐藏状态栏
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;    //设置显示方式
    }
    return self;
}

- (IBAction)cancelBtnClick:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    //半透明黑色背景消失
    [_background removeFromSuperview];
}

- (IBAction)sureBtnClick:(id)sender {
    //获取选中的时间
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    //半透明黑色背景消失
    [_background removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PickerView DataSource
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_cycleItems count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _cycleItems[row];
}

@end
