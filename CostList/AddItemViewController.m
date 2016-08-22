//
//  AddItemViewController.m
//  CostList
//
//  Created by 许德鸿 on 16/8/17.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "AddItemViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "UIView+Category.h"
#import "UIImage+Category.h"
#import "EditLocationViewController.h"
#import "MyDatePickerController.h"

@interface AddItemViewController() <CLLocationManagerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,EditLocationViewControllerDelegate,MyDatePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *moneyTextField;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *photoLabel;
@property (strong,nonatomic) EditLocationViewController *editLocationViewController;
@property (strong,nonatomic) MyDatePickerController *datePickerController;

@end

@implementation AddItemViewController
{
    CLLocationManager *_locationManager; //位置管理器
    CLLocation *_location;  //位置
    CLGeocoder *_geocoder;  //编码器
    CLPlacemark *_placemark;    //地标
    
    UIImagePickerController *_imagePicker;
    UIImage *_image;
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

    [self getLocation];  //获取位置
    [self getCurrentDate];  //获取当前时间
}

- (void)applicationDidEnterBackground
{
    if (_imagePicker != nil) {
        [self dismissViewControllerAnimated:NO completion:nil];
        _imagePicker = nil;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)cancelButtonClick:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)saveButtonClick:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - About add photo methods

- (void)takePhoto
{
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;  //设置为相机
    _imagePicker.delegate = self;
    _imagePicker.allowsEditing = YES;
    
    CGSize backgroundSize = CGSizeMake(_imagePicker.navigationBar.width,_imagePicker.navigationBar.height + StatusBarHeight);
    UIImage *background = [UIImage imageWithColor:GLOBALTINTCOLOR andSize:backgroundSize];
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
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;    //设置为从相册中获取
    _imagePicker.delegate = self;
    _imagePicker.allowsEditing = YES;
    
    CGSize backgroundSize = CGSizeMake(_imagePicker.navigationBar.width,_imagePicker.navigationBar.height + StatusBarHeight);
    UIImage *background = [UIImage imageWithColor:GLOBALTINTCOLOR andSize:backgroundSize];
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
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"添加图片" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *takePhotoBtn = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self takePhoto];   //调用拍照方法
        }];
        UIAlertAction *choosePhotoBtn = [UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self choosePhotoFromLibrary];  //从相册中选择
        }];
        UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [controller addAction:takePhotoBtn];
        [controller addAction:choosePhotoBtn];
        [controller addAction:cancelBtn];
        
        [self presentViewController:controller animated:YES completion:nil];
    } else {
        [self choosePhotoFromLibrary];  //从相册中选择
    }
}

- (void)showImage:(UIImage *)image
{
    self.imageView.image = image;
    self.imageView.hidden = NO;
    self.imageView.frame = CGRectMake(self.photoLabel.x, self.photoLabel.y, 260, 260);
    self.photoLabel.hidden = YES;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    _image = info[UIImagePickerControllerEditedImage];  //获得图片
    [self showImage:_image];    //显示图片
    [self.tableView reloadData];    //更新tableview

    [self dismissViewControllerAnimated:YES completion:nil];
    _imagePicker = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
    _imagePicker = nil;
}

#pragma mark - About get location methods

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
            self.locationLabel.text = @"正在获取位置...";
            self.locationLabel.textColor = [UIColor lightGrayColor];
        }
        else
        {
            self.locationLabel.text = @"禁止获取位置";
            self.locationLabel.textColor = [UIColor lightGrayColor];
        }
    }
    else
    {
        self.locationLabel.text = @"位置服务未开启";
        self.locationLabel.textColor = [UIColor lightGrayColor];
    }
}

-(void)didTimeOut:(id)obj   //获取位置超时方法
{
    [self stopLocationManager]; //停止获取位置
    if(_location == nil)
    {
        self.locationLabel.text = @"无法获取位置";
        self.locationLabel.textColor = [UIColor lightGrayColor];
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
                    self.locationLabel.textColor = [UIColor blackColor];
                    self.locationLabel.text = addressString;
                }
                else
                {
                    self.locationLabel.text = @"无法获取位置";
                    self.locationLabel.textColor = [UIColor lightGrayColor];
                }
            }
            else
            {
                self.locationLabel.text = @"无法获取位置";
                self.locationLabel.textColor = [UIColor lightGrayColor];
            }
            
        }];
    }
}

-(void)geocoderTimeOut:(id)obj  //反编码超时方法
{
    [_geocoder cancelGeocode]; //停止反编码
    if(_placemark == nil)
    {
        self.locationLabel.text = @"无法获取位置";
        self.locationLabel.textColor = [UIColor lightGrayColor];
    }
}

-(void)showLocationMenu
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"请选择位置获取方式" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *editLocationAction = [UIAlertAction actionWithTitle:@"编辑位置" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self showEditLocationView];   //显示编辑位置弹框
    }];
    UIAlertAction *autoGetAction = [UIAlertAction actionWithTitle:@"自动获取" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self getLocation];   //获取位置
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
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

-(void)editedLocation:(NSString *)location
{
    //保存编辑后的位置
    self.locationLabel.text = location;
    self.locationLabel.textColor = [UIColor blackColor];
}

#pragma mark - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self stopLocationManager]; //停止获取位置
    if(error!=nil)
    {
        self.locationLabel.text = @"无法获取位置";
        self.locationLabel.textColor = [UIColor lightGrayColor];
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
-(void)didChooseDate:(NSString *)date
{
    //更新时间标签
    self.timeLabel.text = date;
}

#pragma mark - TableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 3) //添加照片那一行
    {
        [self showPhotoMenu];   //显示获取图片方式的菜单
    }
    else if(indexPath.row == 4) //选择日期那一行
    {
        [self showDatePickerView];  //显示选择日期
    }
    else if(indexPath.row == 5)  //地理位置那一行
    {
        [self showLocationMenu];    //显示位置编辑菜单
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 3)  //添加照片那一行
    {
        if(self.imageView.hidden)
            return [super tableView:tableView heightForRowAtIndexPath:indexPath];
        else
            return 280;
    }
    else
    {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

@end
