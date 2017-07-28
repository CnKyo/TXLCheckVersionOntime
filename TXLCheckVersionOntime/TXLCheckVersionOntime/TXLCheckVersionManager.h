//
//  TXLCheckVersionManager.h
//  TXLCheckVersionOntime
//
//  Created by cocomanber on 2017/7/28.
//  Copyright © 2017年 cocomanber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import  <UIKit/UIKit.h>

@class TXLAppStoreModel;

typedef NS_ENUM(NSInteger, UpdateType){
    UpdateTypeDay,
    UpdateTypeTwoDay,
    UpdateTypeThreeDay,
    UpdateTypeFourDay,
    UpdateTypeFiveDay,
};

typedef void(^checkVersionBlock)(TXLAppStoreModel *model);

@interface TXLCheckVersionManager : NSObject

/**
 单例

 @return 返回单例
 */
+ (instancetype)shareManager;


/**
 *  检测新版本(使用系统默认提示框)
 *
 *  appID:应用在Store里面的ID (应用的AppStore地址里面可获取)
 *  containCtrl: 提示框显示在哪个控制器上
 */
+(void)checkNewEditionWithAppID:(NSString *)appID withCheckType:(UpdateType)type ctrl:(UIViewController *)containCtrl;


/**
 检测新版本(使用自定义提示框)
 
 @param appID 应用在Store里面的ID (应用的AppStore地址里面可获取)
 @param checkVersionBlock AppStore上版本信息回调block
 */
+(void)checkNewEditionWithAppID:(NSString *)appID withCheckType:(UpdateType)type CustomAlert:(checkVersionBlock)checkVersionBlock;

@end
