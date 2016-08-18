//
//  AddItemViewController.m
//  CostList
//
//  Created by 许德鸿 on 16/8/17.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "AddItemViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface AddItemViewController() <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *moneyTextField;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;


@end

@implementation AddItemViewController
{
    CLLocationManager *_locationManager;
    CLLocation *_location;
    CLGeocoder *_geocoder;
    CLPlacemark *_placemark;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //去除多余的空行和分割线
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [self getLocation];  //获取位置
}

- (IBAction)cancelButtonClick:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)saveButtonClick:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - About get location methods

-(void)getLocation
{
    if([CLLocationManager locationServicesEnabled])
    {
        if(([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways))\
        {
            _locationManager = [[CLLocationManager alloc] init];
            _geocoder = [[CLGeocoder alloc] init];
            _location = nil;
            _placemark = nil;
            [self startLocationManager];
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
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [_locationManager startUpdatingLocation];
    
    [self performSelector:@selector(didTimeOut:) withObject:nil afterDelay:50];
}

-(void)stopLocationManager
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(didTimeOut:) object:nil];
    [_locationManager stopUpdatingLocation];
    _locationManager.delegate = nil;
    
    if(_location != nil)
    {
        [self getAddressByLocation];
    }
}

-(void)getAddressByLocation
{
    if(_geocoder != nil)
    {
        [_geocoder reverseGeocodeLocation:_location completionHandler:^(NSArray *placemarks,NSError *error){
            if(error == nil && [placemarks count] > 0)
            {
                _placemark = [placemarks lastObject];
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
    [self stopLocationManager];
    if(_location == nil)
    {
        self.locationLabel.text = @"无法获取位置";
    }
}


#pragma mark - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self stopLocationManager];
    if(error!=nil)
    {
        self.locationLabel.text = @"无法获取位置";
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    _location = [locations lastObject];
    [self stopLocationManager];
}

#pragma mark - TableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 5)
    {
        [self getLocation];  //获取位置
        //这里需要完善
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
