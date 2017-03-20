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
    NSDictionary *_cycleItems;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _cycleItems = @{@0:@"提醒一次",@1:@"每天",@2:@"每周",@3:@"每月",@4:@"每年"};
    
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
    
    //初始化
    if(self.currentCycle == nil)
    {
        [self.cyclePicker selectRow:0 inComponent:0 animated:YES];
    }
    else
    {
        NSArray *keys = [_cycleItems allKeysForObject:self.currentCycle];
        NSNumber *currentNum = [keys firstObject];
        [self.cyclePicker selectRow:[currentNum intValue] inComponent:0 animated:YES];
    }
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
    //获取选中的周期
    NSNumber *chooseNum = @([self.cyclePicker selectedRowInComponent:0]);
    [self.delegate cyclePickerViewController:self didChooseCycle:_cycleItems[chooseNum]];
    
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
    return _cycleItems[@(row)];
}

@end
