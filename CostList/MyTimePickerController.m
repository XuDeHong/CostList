//
//  MyTimePickerController.m
//  CostList
//
//  Created by 许德鸿 on 2017/3/19.
//  Copyright © 2017年 XuDeHong. All rights reserved.
//

#import "MyTimePickerController.h"

@interface MyTimePickerController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation MyTimePickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //创建半透明黑色背景
    self.background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
    //设置时间选择器全局tint color颜色
    self.view.tintColor = GLOBAL_TINT_COLOR;
    
    //初始化时间选择器
    self.datePicker.minimumDate = [NSDate date];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //设置和显示半透明黑色背景
    self.background.backgroundColor = [UIColor blackColor];
    self.background.alpha = 0.5;
    [self.presentingViewController.view addSubview:_background];
    
    if(self.currentTime == nil)
    {
        [self.datePicker setDate:[NSDate date]];
    }
    else
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        //必须有年份才能确定一个时间，否则选择器会出现bug
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSDate *currentTimeStr = [formatter dateFromString:self.currentTime];
        [self.datePicker setDate:currentTimeStr animated:YES];
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
    //获取选中的时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //必须有年份才能确定一个时间，否则选择器会出现bug
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    [self.delegate myTimePickerController:self didChooseTime:[formatter stringFromDate:self.datePicker.date]];
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    //半透明黑色背景消失
    [_background removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
