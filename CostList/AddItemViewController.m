//
//  AddItemViewController.m
//  CostList
//
//  Created by 许德鸿 on 16/8/17.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "AddItemViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "EditLocationViewController.h"
#import "MyDatePickerController.h"
#import <KVNProgress/KVNProgress.h>
#import <SDAutoLayout/SDAutoLayout.h>
#import "ChooseIconViewController.h"
#import "SCNumberKeyBoard.h"
#import "MyImagePickerController.h"
#import "NYTPhotoViewer/NYTPhotosViewController.h"
#import "MyPhoto.h"


#define NavigationBarHeight self.navigationController.navigationBar.height  //导航栏高度

#define ImageViewWidth 180  //图片宽度
#define ImageViewHeight 180 //图片高度
#define ImageCellHeight 200  //图片cell高度

#define IconWidth 30    //图标宽度
#define IconHeight 30   //图标高度
#define IconUpPadding  9    //图标上边空隙
#define IconLeftPadding 8   //图标左边空隙

#define LabelUpPadding 14   //标签上边空隙
#define LabelLeftPadding 8  //标签左边空隙
#define LabelRightPadding 8 //标签右边空隙
#define LabelDownPadding 14 //标签下边空隙

#define TextFieldUpPadding 9    //输入框上边空隙
#define TextFieldLeftPadding 8  //输入框左边空隙
#define TextFieldRightPadding 8 //输入框右边空隙
#define TextFieldDownPadding 9 //输入框下边空隙


#define LocationLabelUpAndDownWhileSpace 28 //位置cell的标签上边和下边空隙之和


@interface AddItemViewController() <CLLocationManagerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,EditLocationViewControllerDelegate,MyDatePickerControllerDelegate,ChooseIconViewControllerDelegate,NYTPhotosViewControllerDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *moneyTextField;   //金额
@property (weak, nonatomic) IBOutlet UITextField *commentTextField; //备注
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;    //时间
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;    //位置
@property (weak, nonatomic) IBOutlet UIImageView *imageView;    //图片
@property (weak, nonatomic) IBOutlet UILabel *photoLabel;   //添加图片文字标签
@property (weak, nonatomic) IBOutlet UIImageView *chooseIcon;   //选择类别图标
@property (weak, nonatomic) IBOutlet UILabel *chooseCategory;   //选择类别标签

@property (strong,nonatomic) EditLocationViewController *editLocationViewController;
@property (strong,nonatomic) MyDatePickerController *datePickerController;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;   //“保存”按钮

@end

@implementation AddItemViewController
{
    CLLocationManager *_locationManager; //位置管理器
    CLLocation *_location;  //位置
    CLGeocoder *_geocoder;  //编码器
    CLPlacemark *_placemark;    //地标
    
    MyImagePickerController *_imagePicker;  //图片选择器
    UIImage *_image;    //图片
    UIImage *_scaleImage;   //缩放后的图片
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //监听app进入后台事件
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    //去除多余的空行和分割线
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [self addGestureToDismissKeyboard]; //添加手势，点击界面其他地方时使键盘消失

    //是否为编辑账目
    if(self.itemToEdit != nil)
    {
        self.navigationItem.title = NSLocalizedString(@"账目详情", @"账目详情");
        [self printDataToEdit]; //显示已有数据
    }
    else
    {
        [self getLocation];  //获取位置
        [self getCurrentDate];  //获取当前时间
    }
    
    [self setupAutoLayout]; //设置自动布局
    
    //自定义数字键盘
    [SCNumberKeyBoard showWithTextField:self.moneyTextField enter:^(UITextField *textField,NSString *number){
        
    } close:^(UITextField *textField,NSString *number){
    
    }];

}

-(void)printDataToEdit
{
    //图标
    self.chooseIcon.image = [UIImage imageNamed:self.itemToEdit.category];
    [self.chooseIcon setAccessibilityIdentifier:self.itemToEdit.category];
    //分类名称
    self.chooseCategory.text = self.itemToEdit.categoryName;
    
    double num = [self.itemToEdit.money doubleValue];
    
    if(num < 0)
    {
        num = fabs(num);    //若为负数则去绝对值
        self.chooseCategory.textColor = [UIColor redColor];
    }
    else
    {
        self.chooseCategory.textColor = [UIColor greenColor];
    }
    //金额
    self.moneyTextField.text = [NSString stringWithFormat:@"%.2lf",num];


    //备注
    self.commentTextField.text = self.itemToEdit.comment;
    //图片
    if ([self.itemToEdit hasPhoto])
    {
        _image = [self.itemToEdit photoImage];
        if(_image != nil)
        {
            _scaleImage = [_image imageCompressForSize:CGSizeMake(ImageViewWidth, ImageViewHeight)];
            [self showImage:_scaleImage];
        }
    }
    //日期
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    self.timeLabel.text = [formatter stringFromDate:self.itemToEdit.date];
    //位置
    if((self.itemToEdit.location != nil) && (![self.itemToEdit.location isEqualToString:@""]))
        [self updateLocationLabel:self.itemToEdit.location withColor:[UIColor blackColor]];
    else
    {
        [self updateLocationLabel:@"没有位置信息" withColor:[UIColor lightGrayColor]];
    }
}

-(void)setupAutoLayout
{
    NSIndexPath *indexPath = nil;
    UIView *contentView = nil;
    UIImageView *icon = nil;
    UITableViewCell *cell = nil;
    
    //金额cell布局
    indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    cell = [self.tableView cellForRowAtIndexPath:indexPath];
    contentView = cell.contentView;
    icon = (UIImageView *)[contentView viewWithTag:501];
    icon.sd_layout.widthIs(IconWidth).heightIs(IconHeight).topSpaceToView(contentView,IconUpPadding).leftSpaceToView(contentView,IconLeftPadding);  //图标布局
    self.moneyTextField.sd_layout.topSpaceToView(contentView,TextFieldUpPadding).leftSpaceToView(icon,TextFieldLeftPadding).rightSpaceToView(contentView,TextFieldRightPadding).bottomSpaceToView(contentView,TextFieldDownPadding); //输入框布局
    
    //备注cell布局
    indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    cell = [self.tableView cellForRowAtIndexPath:indexPath];
    contentView = cell.contentView;
    icon = (UIImageView *)[contentView viewWithTag:502];
    icon.sd_layout.widthIs(IconWidth).heightIs(IconHeight).topSpaceToView(contentView,IconUpPadding).leftSpaceToView(contentView,IconLeftPadding);  //图标布局
    self.commentTextField.sd_layout.topSpaceToView(contentView,TextFieldUpPadding).leftSpaceToView(icon,TextFieldLeftPadding).rightSpaceToView(contentView,TextFieldRightPadding).bottomSpaceToView(contentView,TextFieldDownPadding); //输入框布局
    
    //时间cell布局
    indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    cell = [self.tableView cellForRowAtIndexPath:indexPath];
    contentView = cell.contentView;
    icon = (UIImageView *)[contentView viewWithTag:504];
    icon.sd_layout.widthIs(IconWidth).heightIs(IconHeight).topSpaceToView(contentView,IconUpPadding).leftSpaceToView(contentView,IconLeftPadding);  //图标布局
    self.timeLabel.sd_layout.topSpaceToView(contentView,LabelUpPadding).leftSpaceToView(icon,LabelLeftPadding).rightSpaceToView(contentView,LabelRightPadding).bottomSpaceToView(contentView,LabelDownPadding); //标签布局
    
    //位置cell布局
    indexPath = [NSIndexPath indexPathForRow:1 inSection:2];
    cell = [self.tableView cellForRowAtIndexPath:indexPath];
    contentView = cell.contentView;
    icon = (UIImageView *)[contentView viewWithTag:505];
    icon.sd_layout.widthIs(IconWidth).heightIs(IconHeight).topSpaceToView(contentView,IconUpPadding).leftSpaceToView(contentView,IconLeftPadding);  //图标布局
    self.locationLabel.sd_layout.topSpaceToView(contentView,LabelUpPadding).leftSpaceToView(icon,LabelLeftPadding).rightSpaceToView(contentView,LabelRightPadding); //标签布局
}


- (void)applicationDidEnterBackground
{
    //进入后台后，将图片选择器，日期选择器，位置编辑器和键盘等全部消失
    if (_imagePicker != nil)
    {
        [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
        _imagePicker = nil;
    }
    if(self.datePickerController != nil)
    {
        [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
        //去掉半透明黑色背景
        [self.datePickerController.background removeFromSuperview];
        self.datePickerController = nil;
    }
    if(self.editLocationViewController != nil)
    {
        [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
        self.editLocationViewController = nil;
    }
    [self.view endEditing:YES];
}

- (void)dealloc
{
    //取消监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)cancelButtonClick:(id)sender {
    [self.view endEditing:YES]; //键盘消失
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)saveButtonClick:(id)sender {
    [self.view endEditing:YES]; //键盘消失
    if([self textCategoryAndMoney]) //测试类别是否选择，金额是否正确输入
    {
        KVNProgressConfiguration *configuration = [[KVNProgressConfiguration alloc] init];
        configuration.circleSize = 60.0f;   //设置success图标大小
        configuration.successColor = GLOBAL_TINT_COLOR;   //设置success图标颜色
        configuration.minimumSuccessDisplayTime = 0.8f; //设置动画时间
        configuration.statusFont = [UIFont boldSystemFontOfSize:15.0]; //设置字体大小
        configuration.backgroundFillColor = [UIColor whiteColor];   //设置背景颜色
        configuration.backgroundType = KVNProgressBackgroundTypeSolid;  //设置背景类型
        [KVNProgress setConfiguration:configuration];
        [self getDataToSave];   //保存数据
        [self.delegate addItemViewControllerDidSaveData:self];   //通知代理已经保存数据了
        [KVNProgress showSuccessWithStatus:@"已保存" completion:^{
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}

-(BOOL)textCategoryAndMoney
{
    KVNProgressConfiguration *configuration = [[KVNProgressConfiguration alloc] init];
    configuration.circleSize = 60.0f;   //设置success图标大小
    configuration.errorColor = [UIColor redColor];   //设置success图标颜色
    configuration.minimumErrorDisplayTime = 0.8f; //设置动画时间
    configuration.statusFont = [UIFont boldSystemFontOfSize:15.0]; //设置字体大小
    configuration.backgroundFillColor = [UIColor whiteColor];   //设置背景颜色
    configuration.backgroundType = KVNProgressBackgroundTypeSolid;  //设置背景类型
    [KVNProgress setConfiguration:configuration];

    if([self.chooseCategory.text isEqualToString:@"选择类别"])
    {
        [KVNProgress showErrorWithStatus:@"请选择类别" completion:nil];
        return NO;
    }
    else if([self.moneyTextField.text isEqualToString:@""])
    {
        [KVNProgress showErrorWithStatus:@"请输入金额" completion:nil];
        return NO;
    }
    else if([self.moneyTextField.text isEqualToString:@"0"]  || [self.moneyTextField.text isEqualToString:@"."])
    {
        [KVNProgress showErrorWithStatus:@"请输入正确金额" completion:nil];
        return NO;
    }
    else
        return YES;
}

-(void)getDataToSave
{
    CostItem *dataModel = nil;
    if(self.itemToEdit != nil)
    {
        dataModel = self.itemToEdit;
    }
    else
    {
        dataModel = [self.dataModelHandler createNewDataModel];
        dataModel.photoId = @-1;
    }
    
    //分类
    dataModel.category = [self.chooseIcon accessibilityIdentifier];
    //分类名称
    dataModel.categoryName = self.chooseCategory.text;
    //金额
    if([self.chooseCategory.textColor isEqual:[UIColor redColor]])
        dataModel.money = @(-[self.moneyTextField.text doubleValue]);
    else
        dataModel.money = @([self.moneyTextField.text doubleValue]);
    //备注
    dataModel.comment = self.commentTextField.text;
    //图片
    if(_image != nil)
    {
        if(![dataModel hasPhoto])
        {
            dataModel.photoId = @([CostItem nextPhotoId]);
        }
        NSData *imageData = UIImageJPEGRepresentation(_image, 0.5);
        NSError *error;
        if(![imageData writeToFile:[dataModel photoPath] options:NSDataWritingAtomic error:&error])
        {
            NSLog(@"Error writing file:%@",error);
        }
    }
    else
    {
        if([dataModel hasPhoto])
        {
            if(self.itemToEdit != nil)
                [self.itemToEdit removePhotoFile];  //如果已存在图片则删除
        }
    }
    //时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    dataModel.date = [formatter dateFromString:self.timeLabel.text];
    //保存创建记录的时间，用于排序
    if(self.itemToEdit == nil)
    {
        //获取当前小时，分钟，秒
        NSDate *date = [NSDate date];
        [formatter setDateFormat:@"hh-mm-ss"];
        NSString *current = [formatter stringFromDate:date];
        //设置完整时间格式，年月日是记录中的年月日（可能是过去），时分秒则是创建记录的当前时间
        [formatter setDateFormat:@"yyyy-MM-dd-hh-mm-ss"];
        //获取完整的时间
        NSString *fullString = [NSString stringWithFormat:@"%@-%@",self.timeLabel.text,current];
        
        dataModel.createTime = [formatter dateFromString:fullString];
    }
    //位置
    if(![self.locationLabel.textColor isEqual:[UIColor lightGrayColor]])
        dataModel.location = self.locationLabel.text;
    else
        dataModel.location = @"";
    
    [self.dataModelHandler saveData];
}

-(void)enableTableViewScroll
{
    //检测TableView内容是否超过屏幕，若超过，则可以滚动,否则禁止滚动
    if((self.tableView.contentSize.height + NavigationBarHeight) > SCREEN_HEIGHT || (self.tableView.contentSize.height + NavigationBarHeight) == SCREEN_HEIGHT)
    {
        self.tableView.scrollEnabled = YES;
    }
    else
    {
        self.tableView.scrollEnabled = NO;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ChooseIcon"]) {
        //设置代理
        ChooseIconViewController *controller = segue.destinationViewController;
        controller.delegate = self;
    }
}

#pragma mark - ChooseIconViewController Delegate
-(void)chooseIconViewController:(ChooseIconViewController *)controller didChooseIcon:(NSString *)iconName andDisplayName:(NSAttributedString *)displayName
{
    self.chooseIcon.image = [UIImage imageNamed:iconName];  //更新图标
    [self.chooseIcon setAccessibilityIdentifier:iconName];  //记录图标在Assets.xcassets的名字
    self.chooseCategory.text = [displayName string];    //更新文本
    NSDictionary *dict = [displayName attributesAtIndex:0 effectiveRange:NULL];
    self.chooseCategory.textColor = dict[@"NSColor"];   //设置颜色
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - About dismiss keyboard methods

-(IBAction)dismissKeyBoard :(id)sender
{
    //键盘的return Key按下后键盘消失
    [sender resignFirstResponder];
}

-(void)addGestureToDismissKeyboard
{
    //添加手势
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView =NO;
    [self.view addGestureRecognizer:tapGr];
}

-(void)viewTapped:(UITapGestureRecognizer*)tapGr{
    //点击界面其他地方时使键盘消失
    [self.moneyTextField resignFirstResponder];
    [self.commentTextField resignFirstResponder];
}


#pragma mark - UITextField Delegate

- (BOOL)textField:(UITextField *)theTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //金额最大支持9位整数和两位小数
    NSString *newText = [theTextField.text stringByReplacingCharactersInRange:range withString:string];
    if(![newText containsString:@"."])
    {
        if([newText length] > 9)
        {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - About add photo methods

- (void)takePhoto
{
    _imagePicker = [[MyImagePickerController alloc] init];
    _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;  //设置为相机
    _imagePicker.delegate = self;
    
    CGSize backgroundSize = CGSizeMake(_imagePicker.navigationBar.width,_imagePicker.navigationBar.height + STATUS_BAR_HEIGHT);
    UIImage *background = [UIImage imageWithColor:GLOBAL_TINT_COLOR andSize:backgroundSize];
    //设置导航栏背景图片
    [_imagePicker.navigationBar setBackgroundImage:background forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
    //设置导航栏按钮字体颜色
    _imagePicker.navigationBar.tintColor = [UIColor whiteColor];
    //设置导航栏标题字体颜色
    [_imagePicker.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];

    [self presentViewController:_imagePicker animated:YES completion:nil];
}

- (void)choosePhotoFromLibrary
{
    _imagePicker = [[MyImagePickerController alloc] init];
    _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;    //设置为从相册中获取
    _imagePicker.delegate = self;
    
    CGSize backgroundSize = CGSizeMake(_imagePicker.navigationBar.width,_imagePicker.navigationBar.height + STATUS_BAR_HEIGHT);
    UIImage *background = [UIImage imageWithColor:GLOBAL_TINT_COLOR andSize:backgroundSize];
    //设置导航栏背景图片
    [_imagePicker.navigationBar setBackgroundImage:background forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
    //设置导航栏按钮字体颜色
    _imagePicker.navigationBar.tintColor = [UIColor whiteColor];
    //设置导航栏标题字体颜色
    [_imagePicker.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self presentViewController:_imagePicker animated:YES completion:nil];
}

- (void)showPhotoMenu
{
    //测试摄像头是否可用
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *takePhotoBtn = [UIAlertAction actionWithTitle:NSLocalizedString(@"拍照", @"拍照") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self takePhoto];   //调用拍照方法
        }];
        UIAlertAction *choosePhotoBtn = [UIAlertAction actionWithTitle:NSLocalizedString(@"从相册选择", @"从相册选择") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self choosePhotoFromLibrary];  //从相册中选择
        }];
        UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", @"取消") style:UIAlertActionStyleCancel handler:nil];
        
        if(self.imageView.hidden == NO)
        {
            //查看大图按钮
            UIAlertAction *showOriginImage = [UIAlertAction actionWithTitle:NSLocalizedString(@"查看大图", @"查看大图") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                [self showPhotoViewController];
            }];
            [controller addAction:showOriginImage];
        }
        [controller addAction:takePhotoBtn];
        [controller addAction:choosePhotoBtn];
        [controller addAction:cancelBtn];
        
        [self presentViewController:controller animated:YES completion:nil];
    } else {
        if(self.imageView.hidden == YES)
            [self choosePhotoFromLibrary];  //从相册中选择
        else
        {
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *choosePhotoBtn = [UIAlertAction actionWithTitle:NSLocalizedString(@"从相册选择", @"从相册选择") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                [self choosePhotoFromLibrary];  //从相册中选择
            }];
            UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", @"取消") style:UIAlertActionStyleCancel handler:nil];
            
            if(self.imageView.hidden == NO)
            {
                //查看大图按钮
                UIAlertAction *showOriginImage = [UIAlertAction actionWithTitle:NSLocalizedString(@"查看大图", @"查看大图") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                    [self showPhotoViewController];
                }];
                [controller addAction:showOriginImage];
            }
            [controller addAction:choosePhotoBtn];
            [controller addAction:cancelBtn];
            
            [self presentViewController:controller animated:YES completion:nil];
        }
    }
}

-(void)showPhotoViewController
{
    //创建图片模型
    MyPhoto *photo = [[MyPhoto alloc] init];
    photo.image = _image;
    
     NYTPhotosViewController *photoViewController = [[NYTPhotosViewController alloc] initWithPhotos:@[photo] initialPhoto:nil delegate:self];
    
    UIBarButtonItem *deleteBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deletePhoto)];
    photoViewController.rightBarButtonItem = deleteBtn;    //设置查看大图时右侧按钮

    [self presentViewController:photoViewController animated:YES completion:nil];
}

-(void)deletePhoto
{
    _image = nil;
    _scaleImage = nil;
    self.imageView.hidden = YES;
    self.photoLabel.hidden = NO;
    [self.tableView reloadData];    //更新tableview
    [self enableTableViewScroll]; //检测是否可滚动
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)showImage:(UIImage *)image
{
    self.imageView.image = image;
    self.imageView.hidden = NO;
    self.imageView.frame = CGRectMake(self.photoLabel.x,self.imageView.y,ImageViewWidth,ImageViewHeight);
    self.photoLabel.hidden = YES;

}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    _image = info[UIImagePickerControllerOriginalImage];  //获得图片
    _scaleImage = [_image imageCompressForSize:CGSizeMake(ImageViewWidth, ImageViewHeight)];  //缩放图片
    [self showImage:_scaleImage];    //显示图片
    [self.tableView reloadData];    //更新tableview
    
    [self enableTableViewScroll]; //检测是否可滚动
    
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    _imagePicker = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    _imagePicker = nil;
}

#pragma mark - About get location methods

-(void)updateLocationLabel:(NSString *)text withColor:(UIColor *)color      //根据文本和颜色更新标签
{
    self.locationLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@", @"LocationLabel Text"),text];
    self.locationLabel.textColor = color;

    [self.tableView reloadData];//更新tableview
    [self enableTableViewScroll]; //检测是否可滚动
}

-(void)getLocation
{
    if([CLLocationManager locationServicesEnabled])     //测试位置服务是否开启
    {
        //测试是否允许获取位置
        if(([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways))\
        {
            _locationManager = [[CLLocationManager alloc] init];
            _geocoder = [[CLGeocoder alloc] init];
            _location = nil;
            _placemark = nil;
            [self startLocationManager];    //开始获取位置
            [self updateLocationLabel:@"正在获取位置..." withColor:[UIColor lightGrayColor]];
        }
        else
        {
            [self updateLocationLabel:@"禁止获取位置" withColor:[UIColor lightGrayColor]];
        }
    }
    else
    {
        [self updateLocationLabel:@"位置服务未开启" withColor:[UIColor lightGrayColor]];
    }
}

-(void)didTimeOut:(id)obj   //获取位置超时方法
{
    [self stopLocationManager]; //停止获取位置
    if(_location == nil)
    {
        [self updateLocationLabel:@"无法获取位置" withColor:[UIColor lightGrayColor]];
    }
}

-(void)startLocationManager
{
    _locationManager.delegate = self;   //设置代理
    _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; //设置精准度
    [_locationManager startUpdatingLocation];   //开始获取位置
    
    [self performSelector:@selector(didTimeOut:) withObject:nil afterDelay:25];  //设置超时方法
}

-(void)stopLocationManager
{
    //取消超时方法
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(didTimeOut:) object:nil];
    [_locationManager stopUpdatingLocation];    //停止获取位置
    _locationManager.delegate = nil;
    
    if(_location != nil)    //如果获取到位置
    {
        [self getAddressByLocation];    //反编码
    }
}

-(void)getAddressByLocation
{
    if(_geocoder != nil)
    {
        [self performSelector:@selector(geocoderTimeOut:) withObject:nil afterDelay:25];  //设置超时方法
        [_geocoder reverseGeocodeLocation:_location completionHandler:^(NSArray *placemarks,NSError *error){
            //取消超时方法
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(geocoderTimeOut:) object:nil];
            if(error == nil && [placemarks count] > 0)
            {
                _placemark = [placemarks lastObject];   //获得地标
                if(_placemark != nil)
                {
                    NSArray *lines = _placemark.addressDictionary[@"FormattedAddressLines"];
                    NSString *addressString = [lines componentsJoinedByString:@"\n"];
                    [self updateLocationLabel:addressString withColor:[UIColor blackColor]];
                }
                else
                {
                    [self updateLocationLabel:@"无法获取位置" withColor:[UIColor lightGrayColor]];
                }
            }
            else
            {
                [self updateLocationLabel:@"无法获取位置" withColor:[UIColor lightGrayColor]];
            }
            
        }];
    }
}

-(void)geocoderTimeOut:(id)obj  //反编码超时方法
{
    [_geocoder cancelGeocode]; //停止反编码
    if(_placemark == nil)
    {
        [self updateLocationLabel:@"无法获取位置" withColor:[UIColor lightGrayColor]];
    }
}

-(void)showLocationMenu
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *editLocationAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"编辑位置", @"编辑位置") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self showEditLocationView];   //显示编辑位置弹框
    }];
    UIAlertAction *autoGetAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"自动获取", @"自动获取") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self getLocation];   //获取位置
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", @"取消") style:UIAlertActionStyleCancel handler:nil];
    
    [controller addAction:editLocationAction];
    [controller addAction:autoGetAction];
    [controller addAction:cancelAction];
    
    [self presentViewController:controller animated:YES completion:nil];
}

-(void)showEditLocationView
{
    //设置代理和当前位置
    self.editLocationViewController.delegate = self;
    if(self.locationLabel.textColor == [UIColor blackColor])    //如果是获取到正常的地理位置则赋值，否则置空字符串
        self.editLocationViewController.currentLocation = self.locationLabel.text;
    else
        self.editLocationViewController.currentLocation = @"";
    //显示位置编辑视图
    [self presentViewController:self.editLocationViewController animated:YES completion:nil];
}

#pragma mark - EditLocation View
-(EditLocationViewController *)editLocationViewController
{
    if(!_editLocationViewController)
    {
        _editLocationViewController = [[EditLocationViewController alloc] initWithNibName:@"EditLocationViewController" bundle:nil];
    }
    return _editLocationViewController;
}


#pragma mark - EditLocationViewControllerDelegate

-(void)editLocationViewController:(EditLocationViewController *)controller editedLocation:(NSString *)location
{
    if((location != nil) && (![location isEqualToString:@""]) )
    [self updateLocationLabel:location withColor:[UIColor blackColor]];
}

#pragma mark - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self stopLocationManager]; //停止获取位置
    if(error!=nil)
    {
        [self updateLocationLabel:@"无法获取位置" withColor:[UIColor lightGrayColor]];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    _location = [locations lastObject]; //获得位置
    [self stopLocationManager]; //停止获取位置
}

#pragma mark - About choose date methods

-(void)getCurrentDate
{
    //获取当前时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *now = [NSDate date];
    self.timeLabel.text = [formatter stringFromDate:now];
}

-(MyDatePickerController *)datePickerController
{
    if(!_datePickerController)
    {
        _datePickerController = [[MyDatePickerController alloc] initWithNibName:@"MyDatePickerController" bundle:nil];
    }
    return _datePickerController;
}

-(void)showDatePickerView
{
    //设置日期选择器的时间为标签中显示的时间
    self.datePickerController.currentDate = self.timeLabel.text;
    //设置代理
    self.datePickerController.delegate = self;
    //显示选择日期
    [self presentViewController:self.datePickerController animated:YES completion:nil];
}

#pragma mark - MyDatePickerController Delegate
-(void)myDatePickerController:(MyDatePickerController *)controller didChooseDate:(NSString *)date
{
    //更新时间标签
    self.timeLabel.text = date;
}

#pragma mark - TableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        if(indexPath.row == 1)  //填写金额那一行
        {
            [self.moneyTextField becomeFirstResponder]; //使TextField响应
        }
        else if(indexPath.row == 2) //填写备注那一行
        {
            [self.commentTextField becomeFirstResponder];   //使TextField响应
        }
    }
    else if(indexPath.section == 1) //添加照片那一行
    {
        [self showPhotoMenu];   //显示获取图片方式的菜单
    }
    else
    {
        if(indexPath.row == 0) //选择日期那一行
        {
            [self showDatePickerView];  //显示选择日期
        }
        else if(indexPath.row == 1)  //地理位置那一行
        {
            [self showLocationMenu];    //显示位置编辑菜单
        }
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)setTextAndAdjustLabel:(NSString *)text withLabel:(UILabel *)label
{
    CGFloat maxWidth = label.frame.size.width;  //获取标签宽度
    //根据文本，标签宽度，字体来计算尺寸
    CGRect rect = [text boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName:label.font}
                                     context:nil];
    //更新标签的frame
    label.frame = CGRectMake(label.frame.origin.x,label.frame.origin.y,maxWidth,rect.size.height);
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if((indexPath.section == 2)&&(indexPath.row == 1))  //添加位置那一行
    {
        //根据文本，字体，和标签宽度来计算高度并使标签自适应
        [self setTextAndAdjustLabel:self.locationLabel.text withLabel:self.locationLabel];
        return self.locationLabel.height + LocationLabelUpAndDownWhileSpace;   //返回cell高度
    }
    else if(indexPath.section == 1)  //添加照片那一行
    {
        if(self.imageView.hidden)
            return [super tableView:tableView heightForRowAtIndexPath:indexPath];
        else
            return ImageCellHeight;
    }
    else
    {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

#pragma mark - ScrollView Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //一旦TableView有滑动就使键盘消失
    [self.moneyTextField resignFirstResponder];
    [self.commentTextField resignFirstResponder];
}

@end
