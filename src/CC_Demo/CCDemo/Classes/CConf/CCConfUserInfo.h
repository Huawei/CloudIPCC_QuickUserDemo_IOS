//
//  CConfUserInfo.h
//  CCSDK
//
//  Created by  on 16/5/11.
//  Copyright © 2016年 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "tup_def.h"
@interface CCConfUserInfo : NSObject

@property (nonatomic, assign) TUP_UINT32 userid;//与会者的用户id
@property (nonatomic, assign) TUP_INT32 deviceType;//与会者入会时使用的设备类型,见confsdkdef.h里面的CONF_DEVICE_TYPE枚举定义
@property (nonatomic, copy) NSString* userName;//入会时候的用户名字
@property (nonatomic, assign) TUP_UINT32 deviceId;//入会时候,如果打开了摄像头,摄像头对应的deviceid会存储到这里
@property (nonatomic, copy) NSString* uri;//入会时候使用的uri,通常和入会时候的sip uri一致

@end
