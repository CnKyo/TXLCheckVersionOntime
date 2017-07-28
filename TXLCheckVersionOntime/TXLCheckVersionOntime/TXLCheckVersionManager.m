//
//  TXLCheckVersionManager.m
//  TXLCheckVersionOntime
//
//  Created by cocomanber on 2017/7/28.
//  Copyright © 2017年 cocomanber. All rights reserved.
//

#import "TXLCheckVersionManager.h"
#import "TXLAppStoreModel.h"

@interface TXLCheckVersionManager ()

//本地info文件
@property (nonatomic, strong)NSDictionary *infoDict;

//最近检查时间
@property (nonatomic, assign) NSTimeInterval lastCheckTimeInterval;

@end

@implementation TXLCheckVersionManager

#pragma mark - 懒加载
- (NSDictionary *)infoDict {
    if (!_infoDict) {
        _infoDict = [NSBundle mainBundle].infoDictionary;
    }
    return _infoDict;
}

static TXLCheckVersionManager *_instance = nil;

#pragma mark - 单例
+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    
    _instance.lastCheckTimeInterval = [[NSUserDefaults standardUserDefaults] doubleForKey:@"lastCheckTimeInterval"] ? [[NSUserDefaults standardUserDefaults] doubleForKey:@"lastCheckTimeInterval"] : 0;
    return _instance;
}

#pragma mark - API

+ (void)checkNewEditionWithAppID:(NSString *)appID withCheckType:(UpdateType)type ctrl:(UIViewController *)containCtrl {
    
    [[self shareManager] checkNewVersion:appID withCheckType:type ctrl:containCtrl];
}

+(void)checkNewEditionWithAppID:(NSString *)appID withCheckType:(UpdateType)type CustomAlert:(checkVersionBlock)checkVersionBlock {
    
    if ([[self shareManager] checkTimeIntervalWithCheckType:type]) {
        [[self shareManager] getAppStoreVersion:appID sucess:^(TXLAppStoreModel *model) {
            if(checkVersionBlock)checkVersionBlock(model);
        }];
    }
}

- (void)checkNewVersion:(NSString *)appID withCheckType:(UpdateType)type ctrl:(UIViewController *)containCtrl {
    
    if ([self checkTimeIntervalWithCheckType:type]) {
        //请求appStore信息
        [self getAppStoreVersion:appID sucess:^(TXLAppStoreModel *model) {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"有新的版本(%@)",model.version] message:model.releaseNotes preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *updateAction = [UIAlertAction actionWithTitle:@"立即升级" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self updateRightNow:model];
            }];
            UIAlertAction *delayAction = [UIAlertAction actionWithTitle:@"稍后再说" style:UIAlertActionStyleDefault handler:nil];
            UIAlertAction *ignoreAction = [UIAlertAction actionWithTitle:@"忽略" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self ignoreNewVersion:model.version];
            }];
            [alertController addAction:updateAction];
            [alertController addAction:delayAction];
            [alertController addAction:ignoreAction];
            [containCtrl presentViewController:alertController animated:YES completion:nil];
        }];
    }
}

#pragma mark - 检查时间间隔

-(BOOL)checkTimeIntervalWithCheckType:(UpdateType)type{
    
    BOOL check = NO;
    //如果第一次进来app
    if (!self.lastCheckTimeInterval) {
        //获取当前的时间戳
        self.lastCheckTimeInterval = [[NSDate date] timeIntervalSince1970];
        //存储时间戳
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setDouble:self.lastCheckTimeInterval forKey:@"lastCheckTimeInterval"];
        check = NO;
    }else{
        NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSince1970];
        NSInteger days;
        switch (type) {
            case UpdateTypeDay:
                days = 1;
                break;
                
            case UpdateTypeTwoDay:
                days = 2;
                break;
                
            case UpdateTypeThreeDay:
                days = 3;
                break;
                
            case UpdateTypeFourDay:
                days = 4;
                break;
            case UpdateTypeFiveDay:
                days = 5;
                break;
            default:
                break;
        }
        
        if (currentTimeInterval - self.lastCheckTimeInterval > 60 * 60 * 24 * days) {
            check = YES;
        }else{
            check = NO;
        }
    }
    return check;
}


#pragma mark - 立即升级
- (void)updateRightNow:(TXLAppStoreModel *)model {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:model.trackViewUrl]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:model.trackViewUrl] options:@{} completionHandler:nil];
    }
    
}

#pragma mark - 忽略新版本
- (void)ignoreNewVersion:(NSString *)version {
    //保存忽略的版本号
    [[NSUserDefaults standardUserDefaults] setObject:version forKey:@"ingoreVersion"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - 获取AppStore上的版本信息
- (void)getAppStoreVersion:(NSString *)appID sucess:(void(^)(TXLAppStoreModel *))update {
    
    [self getAppStoreInfo:appID success:^(NSDictionary *respDict) {
        NSInteger resultCount = [respDict[@"resultCount"] integerValue];
        if (resultCount == 1) {
            NSArray *results = respDict[@"results"];
            NSDictionary *appStoreInfo = [results firstObject];
            
            //字典转模型
            TXLAppStoreModel *model = [[TXLAppStoreModel alloc] init];
            [model setValuesForKeysWithDictionary:appStoreInfo];
            //是否提示更新
            BOOL result = [self isEqualEdition:model.version];
            if (result) {
                if(update)update(model);
            }
        } else {
#ifdef DEBUG
            NSLog(@"AppStore上面没有找到对应id的App");
#endif
        }
    }];
    
}

#pragma mark - 返回是否提示更新
-(BOOL)isEqualEdition:(NSString *)newEdition {
    NSString *ignoreVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"ingoreVersion"];
    if([self.infoDict[@"CFBundleShortVersionString"] compare:newEdition] == NSOrderedDescending || [self.infoDict[@"CFBundleShortVersionString"] compare:newEdition] == NSOrderedSame ||
       [ignoreVersion isEqualToString:newEdition]) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - 获取AppStore的info信息
- (void)getAppStoreInfo:(NSString *)appID success:(void(^)(NSDictionary *))success {
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/CN/lookup?id=%@",appID]];
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil && data != nil && data.length > 0) {
                NSDictionary *respDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if (success) {
                    success(respDict);
                }
            }
        });
    }] resume];
}

@end
