//
//  MyDatePickerController.m
//  CostList
//
//  Created by 许德鸿 on 16/8/21.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "MyDatePickerController.h"

@interface MyDatePickerController()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation MyDatePickerController


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //创建半透明黑色背景
    self.background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];

    //设置日期选择器全局tint color颜色
    self.view.tintColor = GLOBAL_TINT_COLOR;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDate *now = [NSDate date];
    
    //获取当前年份
    [formatter setDateFormat:@"yyyy"];
    NSString *currentYear = [formatter stringFromDate:now];
    int year = [currentYear intValue];
    //获取当前月份
    [formatter setDateFormat:@"MM"];
    NSString *currentMon = [formatter stringFromDate:now];
    int month = [currentMon intValue];
    //获取当前日期
    [formatter setDateFormat:@"dd"];
    NSString *currentDay = [formatter stringFromDate:now];
    int day = [currentDay intValue];
    
    //设置最小年份为前五年，最大年份为当前时间
    int minYear = year-5;
    int maxYear = year;
    NSString *minStr = [NSString stringWithFormat:@"%d-01-01",minYear];
    NSString *maxStr = [NSString stringWithFormat:@"%d-%d-%d",maxYear,month,day];
    
    //初始化日期选择器
    [formatter setDateFormat:@"yyyy-MM-dd"];
    self.datePicker.minimumDate = [formatter dateFromString:minStr];
    self.datePicker.maximumDate = [formatter dateFromString:maxStr];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //设置和显示半透明黑色背景
    self.background.backgroundColor = [UIColor blackColor];
    self.background.alpha = 0.5;
    [self.presentingViewController.view addSubview:_background];
    
    //初始化时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    [self.datePicker setDate:[formatter dateFromString:self.currentDate]];
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
    //获取选中的日期
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *chooseDate = self.datePicker.date;
    NSString *dateStr = [formatter stringFromDate:chooseDate];
    //调用代理方法
    [self.delegate myDatePickerController:self didChooseDate:dateStr];
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    //半透明黑色背景消失
    [_background removeFromSuperview];
}

@end
