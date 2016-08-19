//
//  EditLocationViewController.m
//  CostList
//
//  Created by 许德鸿 on 16/8/19.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "EditLocationViewController.h"
#import "UIView+Category.h"

@interface EditLocationViewController ()

@property (weak, nonatomic) IBOutlet UIView *separator1View; //横向分割线
@property (weak, nonatomic) IBOutlet UIView *separator2View; //纵向分割线
@property (weak, nonatomic) IBOutlet UIView *pickerPopView;  //整个PopView
@property (weak,nonatomic) IBOutlet UITextView *textView; //文本区域

@end

@implementation EditLocationViewController
{
    UIView *_backgroundView;  //添加一个半透明黑色背景
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //创建半透明黑色背景
    _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    
    [self customizeAppearence]; //设置UI元素
    
    self.textView.text = self.currentLocation;  //初始化TextView
    [self.textView becomeFirstResponder];
}

-(void)customizeAppearence
{
    //设置月份选择器全局tint color颜色
    self.view.tintColor = GLOBALTINTCOLOR;
    
    //设置两条分割线的颜色
    self.separator1View.backgroundColor=self.separator2View.backgroundColor=GLOBALTINTCOLOR;
    
    //设置圆角
    self.pickerPopView.layer.cornerRadius = 10.0f;
    
    //设置半透明黑色背景
    _backgroundView.backgroundColor = [UIColor blackColor];
    _backgroundView.alpha = 0.0;//初始先是全透明
    
    //设置整个月份选择器水平居中
    self.pickerPopView.centerX = (SCREENWIDTH / 2.0f);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        //设置初始化时MonthPickerView在屏幕上方（看不见）
        self.view.y = 0 - SCREENHEIGHT;
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
    
    //月份选择器从屏幕上方滑下来动画
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
    
    //月份选择器从屏幕向上滑离屏幕
    [UIView animateWithDuration:0.3 animations:^{
        self.view.y = 0 - SCREENHEIGHT;
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
    
    //调用协议方法
    [self.delegate editedLocation:self.textView.text];
    [self dismissFromParentViewController];
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
