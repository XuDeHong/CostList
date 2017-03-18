//
//  SlideMenuViewController.m
//  CostList
//
//  Created by 许德鸿 on 16/8/31.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "SlideMenuViewController.h"
#import "SlideNavigationViewController.h"
#import "GRRequestsManager.h"
#import <KVNProgress/KVNProgress.h>
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>

#define DocumentsDirectory [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

#if TARGET_IPHONE_SIMULATOR
//模拟器数据存入服务器的simulator文件夹
#define RemoteDirectory [NSString stringWithFormat:@"/simulator"]
#else
//真机数据存入服务器的real文件夹
#define RemoteDirectory [NSString stringWithFormat:@"/real"]
#endif

@interface SlideMenuViewController () <GRRequestsManagerDelegate>

@property (weak,nonatomic) SlideNavigationViewController *slideNavigationController;
@property (nonatomic, strong) GRRequestsManager *requestsManager;   //FTP管理器

@end

@implementation SlideMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //初始化FTP管理器
    self.requestsManager = [[GRRequestsManager alloc] initWithHostname:@"182.61.19.53" user:@"chris" password:@"123456"];
    self.requestsManager.delegate = self;
    //配置弹框
    KVNProgressConfiguration *configuration = [[KVNProgressConfiguration alloc] init];
    configuration.circleSize = 60.0f;   //设置success图标大小
    configuration.successColor = GLOBAL_TINT_COLOR;   //设置success图标颜色
    configuration.circleStrokeForegroundColor = GLOBAL_TINT_COLOR;  //设置旋转圆圈颜色
    configuration.minimumSuccessDisplayTime = 0.8f; //设置动画时间
    configuration.statusFont = [UIFont boldSystemFontOfSize:15.0]; //设置字体大小
    configuration.backgroundFillColor = [UIColor whiteColor];   //设置背景颜色
    configuration.backgroundType = KVNProgressBackgroundTypeSolid;  //设置背景类型
    [KVNProgress setConfiguration:configuration];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 同步数据

//从服务器下载数据到本地
- (void)downloadData
{
    [KVNProgress showWithStatus:@"正在下载"];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    //获取服务器上保存的所有文件
    [self.requestsManager addRequestForListDirectoryAtPath:RemoteDirectory];
    
    [self.requestsManager startProcessingRequests];
}

//从本地上传数据到服务器
- (void)uploadData
{
    [KVNProgress showWithStatus:@"正在上传"];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath:DocumentsDirectory];
    NSString *fileName;
    NSString *localPath;
    NSString *remotePath;
    //枚举Documents文件夹，将所有文件上传到服务器
    while (fileName = [dirEnum nextObject])
    {
        localPath = [DocumentsDirectory stringByAppendingPathComponent:fileName];
        remotePath = [RemoteDirectory stringByAppendingPathComponent:fileName];
        [self.requestsManager addRequestForUploadFileAtLocalPath:localPath toRemotePath:remotePath];
    }
    //以PhotoID为名在服务器创建一个空白文件夹
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger photoId = [defaults integerForKey:@"PhotoID"];
    NSString *idFileName = [NSString stringWithFormat:@"ID%ld",(long)photoId];
    remotePath = [RemoteDirectory stringByAppendingPathComponent:idFileName];
    [self.requestsManager addRequestForCreateDirectoryAtPath:remotePath];
    
    [self.requestsManager startProcessingRequests];
}

#pragma mark - GRRequestsManagerDelegate

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didScheduleRequest:(id<GRRequestProtocol>)request
{
    NSLog(@"requestsManager:didScheduleRequest:");
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompleteListingRequest:(id<GRRequestProtocol>)request listing:(NSArray *)listing
{
    NSLog(@"requestsManager:didCompleteListingRequest:listing: \n%@", listing);
    
    //枚举服务器的文件名列表
    for(NSString *fileName in listing)
    {
        if([fileName containsString:@"ID"])
        {   //根据空白文件夹名更新用户配置的PhotoID
            NSString *photoID = [fileName stringByReplacingOccurrencesOfString:@"ID" withString:@""];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setInteger:[photoID integerValue] forKey:@"PhotoID"];
            [defaults synchronize];
        }
        else
        {   //除空白文件夹外，其余文件都下载到Documents
            NSString *localPath = [DocumentsDirectory stringByAppendingPathComponent:fileName];
            NSString *remotePath = [RemoteDirectory stringByAppendingPathComponent:fileName];
            [self.requestsManager addRequestForDownloadFileAtRemotePath:remotePath toLocalPath:localPath];
        }
    }

    [self.requestsManager startProcessingRequests];
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompleteCreateDirectoryRequest:(id<GRRequestProtocol>)request
{
    NSLog(@"requestsManager:didCompleteCreateDirectoryRequest:");
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompleteDeleteRequest:(id<GRRequestProtocol>)request
{
    NSLog(@"requestsManager:didCompleteDeleteRequest:");
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompletePercent:(float)percent forRequest:(id<GRRequestProtocol>)request
{
    NSLog(@"requestsManager:didCompletePercent:forRequest: %f", percent);
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompleteUploadRequest:(id<GRDataExchangeRequestProtocol>)request
{
    NSLog(@"requestsManager:didCompleteUploadRequest:");
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompleteDownloadRequest:(id<GRDataExchangeRequestProtocol>)request
{
    NSLog(@"requestsManager:didCompleteDownloadRequest:");
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didFailWritingFileAtPath:(NSString *)path forRequest:(id<GRDataExchangeRequestProtocol>)request error:(NSError *)error
{
    NSLog(@"requestsManager:didFailWritingFileAtPath:forRequest:error: \n %@", error);
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didFailRequest:(id<GRRequestProtocol>)request withError:(NSError *)error
{
    NSLog(@"requestsManager:didFailRequest:withError: \n %@", error);
}

-(void)requestsManagerDidCompleteQueue:(id<GRRequestsManagerProtocol>)requestsManager
{
    NSLog(@"requestsManagerDidCompleteQueue:");
    
    [KVNProgress showSuccessWithStatus:@"已完成" completion:nil];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


#pragma mark -

-(SlideNavigationViewController *)slideNavigationController
{
    if(!_slideNavigationController)
    {
        _slideNavigationController = (SlideNavigationViewController *)self.navigationController;
    }
    return _slideNavigationController;
}

- (IBAction)cancelBtnDidClick:(id)sender {
    //由右向左滑走
    self.slideNavigationController.isVisible = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.navigationController.view.x = 0 - SCREEN_WIDTH;
    } completion:^(BOOL finished){
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];
}

-(void)confirmDeleteAllData
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"注意", @"注意") message:NSLocalizedString(@"确定要清空所有数据吗？（数据清空后不可恢复）",@"确定要清空所有数据吗？（数据清空后不可恢复）") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureBtn = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", @"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
        [self deleteAllData];
    }];
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", @"取消") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
    }];
    [controller addAction:sureBtn];
    [controller addAction:cancelBtn];
    [self presentViewController:controller animated:YES completion:nil];
}

-(void)deleteAllData
{
    //清空所有数据
    NSString *DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:DocumentsPath];
    for (NSString *fileName in enumerator) {
        [[NSFileManager defaultManager] removeItemAtPath:[DocumentsPath stringByAppendingPathComponent:fileName] error:nil];
    }
    //重置PhotoID
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:0 forKey:@"PhotoID"];
    [defaults synchronize];
    
    [KVNProgress showSuccessWithStatus:@"已清空数据" completion:nil];
}

-(void)dataSynchronismAlertSheet
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *upload = [UIAlertAction actionWithTitle:NSLocalizedString(@"上传到服务器", @"上传到服务器") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self uploadData];
    }];
    UIAlertAction *download = [UIAlertAction actionWithTitle:NSLocalizedString(@"从服务器下载", @"从服务器下载") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self downloadData];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", @"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
    }];
    [controller addAction:upload];
    [controller addAction:download];
    [controller addAction:cancel];
    [self presentViewController:controller animated:YES completion:nil];
}

-(void)shareMyApp
{
    //1、创建分享参数
    NSArray* imageArray = @[[UIImage imageNamed:@"logo.png"]];
    if (imageArray)
    {
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        [shareParams SSDKSetupShareParamsByText:@"这是我独立开发的一个移动记账APP" images:imageArray url:[NSURL URLWithString:@"https://github.com/XuDeHong/CostList"] title:@"分享移动记账" type:SSDKContentTypeAuto];
        //有的平台要客户端分享需要加此方法，例如微博
        [shareParams SSDKEnableUseClientShare];
        //2、分享（可以弹出我们的分享菜单和编辑界面）
        [ShareSDK showShareActionSheet:nil items:nil shareParams:shareParams onShareStateChanged:
         ^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end)
        {
            switch (state)
            {
                case SSDKResponseStateSuccess:
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功" message:nil delegate:nil cancelButtonTitle:@"确定"otherButtonTitles:nil];[alertView show];
                  break;
                }
                case SSDKResponseStateFail:
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"message:[NSString stringWithFormat:@"%@",error]delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil, nil];
                        [alert show];
                    break;
                }
                default:
                    break;
            }
        }
    ];}
}

#pragma mark - Table View Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && indexPath.row == 2)    //清空数据
    {
        [self confirmDeleteAllData];
    }
    else if(indexPath.section == 0 && indexPath.row == 3)    //数据同步
    {
        [self dataSynchronismAlertSheet];
    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {   //意见反馈，调用系统邮箱写邮件
        [[UIApplication sharedApplication]openURL:[NSURL   URLWithString:@"mailto:DeHongBoy@outlook.com"]];
    }
    else if(indexPath.section == 2 && indexPath.row == 0)
    {   //分享应用
        [self shareMyApp];
    }
    else if(indexPath.section == 2 && indexPath.row == 1)
    {   //评分鼓励，跳转到safari
        [[UIApplication sharedApplication]openURL:[NSURL   URLWithString:@"https://github.com/XuDeHong/CostList"]];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return tableView.rowHeight;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN; //没有footer
}
@end
