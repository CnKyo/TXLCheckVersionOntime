//
//  TXLAppStoreModel.h
//  TXLCheckVersionOntime
//
//  Created by cocomanber on 2017/7/28.
//  Copyright © 2017年 cocomanber. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TXLAppStoreModel : NSObject

/**
 *  版本号
 */
@property(nonatomic,copy) NSString * version;

/**
 *  更新日志
 */
@property(nonatomic,copy)NSString *releaseNotes;

/**
 *  更新时间
 */
@property(nonatomic,copy)NSString *currentVersionReleaseDate;


/**
 *  AppStore地址
 */
@property(nonatomic,copy)NSString *trackViewUrl;

@end
