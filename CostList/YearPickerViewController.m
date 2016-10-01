//
//  YearPickerViewController.m
//  CostList
//
//  Created by 许德鸿 on 16/8/12.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "YearPickerViewController.h"

@interface YearPickerViewController () <UIPickerViewDelegate,UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *separator1View; //横向分割线
@property (weak, nonatomic) IBOutlet UIView *separator2View; //纵向分割线
@property (weak, nonatomic) IBOutlet UIView *pickerPopView;  //整个PopView
@property (weak, nonatomic) IBOutlet UIPickerView *yearPickerView; //PickerView
@property (strong,nonatomic) NSMutableArray *yearArray;

@end

@implementation YearPickerViewController
{
    UIView *_backgroundView;  //添加一个半透明黑色背景
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //创建半透明黑色背景
    _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
    [self customizeAppearence]; //设置UI元素
}

-(void)viewDidLayoutSubviews
//!!!注意，这个方法只在第一次弹出月份选择器时调用一两次，因为是从NIB文件中加载并且是以子视图控制器的方式嵌入到父视图控制器。而对于月份这个数据，只有月份选择器可以改变，月份选择器按钮显示结果。而在添加账目的地理位置那里，地理位置Label的修改可以是通过自动获取，也可以是通过位置编辑弹框修改
{
    [super viewDidLayoutSubviews];
    
    //以下代码如果放在viewDidLoad则会出错，因为在NIB文件中引用了self.view，这时viewDidLoad会提前加载，而控制器的一些属性，变量等就还没加载完，所以只能把这些代码放在viewDidLayoutSubviews
    //从年份选择器按钮获取年份
    NSString *year = [self.currentYear substringWithRange:NSMakeRange(0, 4)];
    //计算年份在数组的序号
    int thisYear = [year intValue] - ([[[self.yearArray lastObject] substringWithRange:NSMakeRange(0, 4)]  intValue] - 4);
    
    //设置年份选择器为年份选择器按钮的年份（初始化）
    [self.yearPickerView selectRow:thisYear inComponent:0 animated:NO];
    
}

//惰性实例化
-(NSMutableArray *)yearArray{
    if (!_yearArray) {
        _yearArray = [[NSMutableArray alloc]init];
        
        //创建日期格式器
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy"];
        //获取当前年份
        NSString *thisYear = [formatter stringFromDate:[NSDate date]];
        int year = [thisYear intValue];
        
        //设置为5年内
        for (int i = year - 4; i <=year; i++) {
            NSString *str = [NSString stringWithFormat:@"%d%@",i,@"年"];
            [_yearArray addObject:str];
        }
    }
    return _yearArray;
}

-(void)customizeAppearence
{
    //设置年份选择器全局tint color颜色
    self.view.tintColor = GLOBAL_TINT_COLOR;
    
    //设置两条分割线的颜色
    self.separator1View.backgroundColor = self.separator2View.backgroundColor = GLOBAL_TINT_COLOR;
    
    //设置圆角
    self.pickerPopView.layer.cornerRadius = 10.0f;
    
    //设置半透明黑色背景
    _backgroundView.backgroundColor = [UIColor blackColor];
    _backgroundView.alpha = 0.0;//初始先是全透明
    
    //设置整个年份选择器水平居中
    self.pickerPopView.centerX = (SCREEN_WIDTH / 2.0f);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        //设置初始化时YearPickerView在屏幕上方（看不见）
        self.view.y = 0 - SCREEN_HEIGHT;
    }
    
    return self;
}

-(void)presentInParentViewController:(UIViewController *)parentViewController
{
    //动画显示半透明黑色背景
    [UIView animateWithDuration:0.2 animations:^{
        _backgroundView.alpha = 0.5;
        [parentViewController.view addSubview:_backgroundView];
    }];
    
    //年份选择器从屏幕上方滑下来动画
    [UIView animateWithDuration:0.3 animations:^{
        self.view.y = 0;
        [parentViewController.view addSubview:self.view];
        [parentViewController addChildViewController:self];
    } completion:^(BOOL finished){
        [self didMoveToParentViewController:self.parentViewController];
    }];
}

-(void)dismissFromParentViewController
{
    [self willMoveToParentViewController:nil];
    
    //年份选择器从屏幕向上滑离屏幕
    [UIView animateWithDuration:0.3 animations:^{
        self.view.y = 0 - SCREEN_HEIGHT;
    } completion:^(BOOL finished){
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
    
    //半透明黑色背景消失
    [UIView animateWithDuration:0.2 animations:^{
        _backgroundView.alpha = 0.0;
        [_backgroundView removeFromSuperview];
    }];
}

- (IBAction)cancelBtnClick:(id)sender {
    [self dismissFromParentViewController];
}

- (IBAction)sureBtnClick:(id)sender {
    
    //获取选择的年份
    NSInteger yearRow = [self.yearPickerView selectedRowInComponent:0];
    NSString *selectedYear = self.yearArray[yearRow];
    
    //调用协议方法
    [self.delegate yearPickerViewController:self chooseYear:[NSString stringWithFormat:@"%@",selectedYear]];
    [self dismissFromParentViewController];
}

#pragma mark  - PickerView Data Source
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component {
    return [self.yearArray count];
}

#pragma mark PickerView Delegate
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
        return self.yearArray[row];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        // Setup label properties - frame, font, colors etc
        //adjustsFontSizeToFitWidth property to YES
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        pickerLabel.textAlignment = NSTextAlignmentCenter;
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont systemFontOfSize:18.0f]];
    }
    // Fill the label text here
    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
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
