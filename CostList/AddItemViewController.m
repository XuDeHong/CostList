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

@interface AddItemViewController() <CLLocationManagerDelegate,UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *moneyTextField;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *photoLabel;


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
}

- (void)applicationDidEnterBackground
{
    if (_imagePicker != nil) {
        [self dismissViewControllerAnimated:NO completion:nil];
        _imagePicker = nil;
    }
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
    _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    _imagePicker.delegate = self;
    _imagePicker.allowsEditing = YES;
    _imagePicker.view.tintColor = GLOBALTINTCOLOR;
    [self presentViewController:_imagePicker animated:YES completion:nil];
}

- (void)choosePhotoFromLibrary
{
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _imagePicker.delegate = self;
    _imagePicker.allowsEditing = YES;
    _imagePicker.view.tintColor = GLOBALTINTCOLOR;
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
    self.imageView.frame = CGRectMake(46, 14, 260, 260);
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
        }
        else
        {
            self.locationLabel.text = @"禁止获取位置";
        }
    }
    else
    {
        self.locationLabel.text = @"位置服务未开启";
    }
}


-(void)startLocationManager
{
    _locationManager.delegate = self;   //设置代理
    _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; //设置精准度
    [_locationManager startUpdatingLocation];   //开始获取位置
    
    [self performSelector:@selector(didTimeOut:) withObject:nil afterDelay:50];  //设置超时方法
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
        [_geocoder reverseGeocodeLocation:_location completionHandler:^(NSArray *placemarks,NSError *error){
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
                }
            }
            else
            {
                self.locationLabel.text = @"无法获取位置";
            }
        }];
    }
}

-(void)didTimeOut:(id)obj
{
    [self stopLocationManager]; //停止获取位置
    if(_location == nil)
    {
        self.locationLabel.text = @"无法获取位置";
    }
}

-(void)showLocationMenu
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"请选择位置获取方式" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *editLocationAction = [UIAlertAction actionWithTitle:@"编辑位置" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self showEditLocationAlert];   //显示编辑位置弹框
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

-(void)showEditLocationAlert        //有问题
{
    __block int tag=0;
    __block NSString *editLocation;
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"编辑位置" message:@"请输入你想要保存的地理位置" preferredStyle:UIAlertControllerStyleAlert];
    [controller addTextFieldWithConfigurationHandler:^(UITextField *textField){
        editLocation = textField.text;
    }];
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *saveBtn = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        tag = 1;
    }];
    
    if(tag)
    {
        self.locationLabel.text = editLocation;
    }
    
    [controller addAction:cancelBtn];
    [controller addAction:saveBtn];
    
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self stopLocationManager]; //停止获取位置
    if(error!=nil)
    {
        self.locationLabel.text = @"无法获取位置";
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    _location = [locations lastObject]; //获得位置
    [self stopLocationManager]; //停止获取位置
}

#pragma mark - TableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 5)  //地理位置那一行
    {
        [self showLocationMenu];    //显示位置编辑菜单
    }
    else if(indexPath.row == 3) //添加照片那一行
    {
        [self showPhotoMenu];
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
