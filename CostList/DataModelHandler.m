//
//  DataModelHandler.m
//  CostList
//
//  Created by 许德鸿 on 2016/10/21.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "DataModelHandler.h"

@interface DataModelHandler()

@property (nonatomic,strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic,strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

//CoreData错误通知
NSString * const ManagedObjectContextSaveDidFailNotification = @"ManagedObjectContextSaveDidFailNotification";

@implementation DataModelHandler

-(instancetype)init
{
    self = [super init];
    if(self)
    {
        //设置当接收到CoreData错误通知时调用方法
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fatalCoreDataError:) name:ManagedObjectContextSaveDidFailNotification object:nil];
    }
    return self;
}

-(CostItem *)createNewDataModel
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"CostItem" inManagedObjectContext:self.managedObjectContext];
}

-(BOOL)saveData
{
    NSError *error;
    if(![self.managedObjectContext save:&error])
    {
        FATAL_CORE_DATA_ERROR(error);   //处理错误情况
        return NO;
    }
    return YES;
}

-(BOOL)deleteData:(CostItem *)data
{
    [data removePhotoFile];    //删除图片
    
    [self.managedObjectContext deleteObject:data];
    
    NSError *error;
    if(![self.managedObjectContext save:&error])
    {
        FATAL_CORE_DATA_ERROR(error);
        return NO;
    }
    return YES;
}

-(NSArray *)searchDataByText:(NSString *)text
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CostItem" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    //设置过滤器
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"comment CONTAINS %@",text];
    
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *foundObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if((foundObjects == nil) || (foundObjects.count == 0))    //从CoreData中获取数据
    {
        return nil;
    }
    else
    {
        return foundObjects;
    }

}

#pragma mark - Core Data
-(NSManagedObjectModel *)managedObjectModel
{
    if(_managedObjectModel == nil)
    {
        NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"DataModel" ofType:@"momd"];
        NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return _managedObjectModel;
}

-(NSString *)documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths lastObject];
    NSLog(@"%@",documentsDirectory);
    return documentsDirectory;
}

-(NSString *)dataStorePath
{
    return [[self documentsDirectory] stringByAppendingPathComponent:@"DataStore.sqlite"];
}

-(NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if(_persistentStoreCoordinator == nil)
    {
        NSURL *storeURL = [NSURL fileURLWithPath:[self dataStorePath]];
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        NSError *error;
        if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
        {
            NSLog(@"Error adding persistent store %@,%@",error,[error userInfo]);
            abort();
        }
    }
    return _persistentStoreCoordinator;
    
}

-(NSManagedObjectContext *)managedObjectContext
{
    if(_managedObjectContext == nil)
    {
        NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
        if(coordinator != nil)
        {
            _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        }
    }
    return _managedObjectContext;
}

-(void)fatalCoreDataError:(NSNotification *)notification
{
    //处理错误情况
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"内部错误" message:@"There was a fatal error in the app and it cannot continue.\n\nPress OK to terminate the app. Sorry for the inconvenience." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        abort();
    }];
    [controller addAction:action];
    [ROOT_VIEW_CONTROLLER presentViewController:controller animated:YES completion:nil];
}

@end
