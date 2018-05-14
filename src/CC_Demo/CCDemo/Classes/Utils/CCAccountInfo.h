//
//  CCAccountInfo.h
//  CCSDK
//
//  Created by  on 16/4/1.
//  Copyright © 2016年 . All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger,CHAT_CALL_STATUS)
{
    CHAT_NOT_CONNECTED,
    CHAT_CONNECTED
};

typedef NS_ENUM(NSUInteger,CALL_QUEUE_STATUS)
{
    CALL_QUEUE_NOT,
    CALL_QUEUE_IS
};

@interface CCAccountInfo : NSObject

@property (nonatomic, copy) NSString *serverAddr;
@property (nonatomic, copy) NSString *vndID;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *loginPath;
@property (nonatomic, copy) NSString *logoutPath;
@property (nonatomic, copy) NSString *tpConpath;
@property (nonatomic, copy) NSString *msConPath;
@property (nonatomic, copy) NSString *chatCallPath;
@property (nonatomic, copy) NSString *eventPath;
@property (nonatomic, copy) NSString *confPath;
@property (nonatomic, copy) NSString *stopConfPath;
@property (nonatomic, copy) NSString *sendMsgPath;
@property (nonatomic, copy) NSString *queueInfoPath;
@property (nonatomic, copy) NSString *releasePath;
@property (nonatomic,copy) NSString *verifyCodePath;
@property (nonatomic, assign) CHAT_CALL_STATUS chatStatus;
@property (nonatomic, assign) CALL_QUEUE_STATUS queueStatus;
@property (nonatomic, copy) NSString *cookie;
@property (nonatomic, copy) NSString *guid;
@property (nonatomic, copy) NSString *result;
@property (nonatomic, copy) NSString *sendCallid;

@property (nonatomic,copy) NSString *clickToDial;
@property (nonatomic,copy) NSString *uvid;
@property (nonatomic,copy) NSString *stopConfId;

+ (CCAccountInfo *)shareInstance;

@end
