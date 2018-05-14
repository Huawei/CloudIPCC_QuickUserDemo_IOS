//
//  CConstantInfo.h
//  CCIOSSDK
//
//  Created by  on 16/7/8.
//  Copyright © 2016年 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCCommonDefine.h"
#import "call_def.h"


@interface CCConstantInfo : NSObject

@property (nonatomic, assign) int serverType;
@property (nonatomic, copy) NSString *callType;
@property (nonatomic, copy) NSString *logPath;
@property (nonatomic, assign) CCLogLevel logLevel;

@property (nonatomic, strong) NSData *dataCA;
@property (nonatomic, strong) NSData *dataClient;
@property (nonatomic, copy) NSString *certificatePassword;
@property (nonatomic, assign) BOOL isNeedValidateDomainName;
@property (nonatomic, assign) BOOL needValidate;

+ (CCConstantInfo *)shareInstance;
@end
