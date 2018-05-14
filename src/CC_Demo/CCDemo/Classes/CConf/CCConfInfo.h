//
//  CConfInfo.h
//  CCSDK
//
//  Created by  on 16/5/9.
//  Copyright © 2016年 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "tup_def.h"

@interface CCConfInfo : NSObject

@property (nonatomic, assign) TUP_UINT32 confId;//会议ID，一般需要服务器创建后提供
@property (nonatomic, assign) TUP_UINT32 userId;//用户ID，会议中用户的唯一标识，外部定义
@property (nonatomic, assign) TUP_UINT32 userType;//用户类型，必选：主持人 1、主讲人2 和普通与会者8
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *hostKey;//主持人密码：主持人入会必须设置，其他情况不需要
@property (nonatomic, copy) NSString *siteId;//站点ID
@property (nonatomic, copy) NSString *siteUrl;//会议网站地址，IPT方案中为U19的地址
@property (nonatomic, copy) NSString *msServerIp;//会议服务器地址，单个地址或URL
@property (nonatomic, copy) NSString *encryptKey;//会议鉴权密码
@property (nonatomic, copy) NSString *confTitle;
@property (nonatomic, copy) NSString *logUri;

@end
