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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self customizeAppearence]; //设置UI元素
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //初始化TextView
    self.textView.text = self.currentLocation;
    self.textView.layer.borderWidth = 1.0;
    self.textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.textView becomeFirstResponder];
}

-(void)customizeAppearence
{
    //设置位置编辑器全局tint color颜色
    self.view.tintColor = GLOBALTINTCOLOR;
    
    //设置两条分割线的颜色
    self.separator1View.backgroundColor=self.separator2View.backgroundColor=GLOBALTINTCOLOR;
    
    //设置圆角
    self.pickerPopView.layer.cornerRadius = 10.0f;
    
    //设置整个位置编辑器水平居中
    self.pickerPopView.centerX = (SCREENWIDTH / 2.0f);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;    //设置显示方式
        //设置显示动画，交叉溶解显示动画，月份选择器的显示动画是从上滑下来
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}


- (IBAction)cancelBtnClick:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sureBtnClick:(id)sender {
    
    //调用协议方法
    [self.delegate editedLocation:self.textView.text];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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
