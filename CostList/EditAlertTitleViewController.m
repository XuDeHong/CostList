//
//  EditAlertTitleViewController.m
//  CostList
//
//  Created by 许德鸿 on 2017/3/20.
//  Copyright © 2017年 XuDeHong. All rights reserved.
//

#import "EditAlertTitleViewController.h"

#define MAX_LIMIT_NUMS  10 //限制最大输入只能20个字符

@interface EditAlertTitleViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *separator1View; //横向分割线
@property (weak, nonatomic) IBOutlet UIView *separator2View; //纵向分割线
@property (weak, nonatomic) IBOutlet UIView *pickerPopView;  //整个PopView
@property (weak,nonatomic) IBOutlet UITextView *textView; //文本区域

@end

@implementation EditAlertTitleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self customizeAppearence]; //设置UI元素
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //初始化TextView
    self.textView.text = self.currentTitle;
    self.textView.layer.borderWidth = 1.0;
    self.textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.textView becomeFirstResponder];
}

-(void)customizeAppearence
{
    //设置位置编辑器全局tint color颜色
    self.view.tintColor = GLOBAL_TINT_COLOR;
    
    //设置两条分割线的颜色
    self.separator1View.backgroundColor=self.separator2View.backgroundColor=GLOBAL_TINT_COLOR;
    
    //设置圆角
    self.pickerPopView.layer.cornerRadius = 10.0f;
    
    //设置整个编辑器水平居中
    self.pickerPopView.centerX = (SCREEN_WIDTH / 2.0f);
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
    [self.textView resignFirstResponder]; //键盘消失
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sureBtnClick:(id)sender {
    [self.textView resignFirstResponder]; //键盘消失
    //调用协议方法
    [self.delegate editAlertTitleViewController:self editedAlertTitle:self.textView.text];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextView Delegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        //在这里做你响应return键的代码
        [self performSelector:@selector(sureBtnClick:) withObject:nil];     //调用“确定”按钮响应方法
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    
    NSString *newText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if([newText length] > MAX_LIMIT_NUMS)
    {
        return NO;
    }
    return YES;
}

@end
