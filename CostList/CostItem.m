//
//  CostItem.m
//  CostList
//
//  Created by 许德鸿 on 16/9/9.
//  Copyright © 2016年 XuDeHong. All rights reserved.
//

#import "CostItem.h"

@implementation CostItem

// Insert code here to add functionality to your managed object subclass
-(BOOL)hasPhoto
{
    return (self.photoId != nil) && ([self.photoId integerValue] != -1);
}

-(NSString *)documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths lastObject];
    return documentsDirectory;
}

-(NSString *)photoPath
{
    NSString *filename = [NSString stringWithFormat:@"Photo-%ld.jpg",(long)[self.photoId integerValue]];
    return [[self documentsDirectory] stringByAppendingPathComponent:filename];
}

-(UIImage *)photoImage
{
    NSAssert(self.photoId != nil, @"No photo ID set");
    NSAssert([self.photoId integerValue] != -1, @"Photo ID is -1");
    NSLog(@"%@",[self photoPath]);
    return [UIImage imageWithContentsOfFile:[self photoPath]];
}

+(NSInteger)nextPhotoId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger photoId = [defaults integerForKey:@"PhotoID"];
    [defaults setInteger:photoId+1 forKey:@"PhotoID"];
    [defaults synchronize];
    return photoId;
}

-(void)removePhotoFile
{
    NSString *path = [self photoPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:path])
    {
        NSError *error;
        if(![fileManager removeItemAtPath:path error:&error])
        {
            NSLog(@"Error removing file:%@",error);
        }
    }
}


@end
